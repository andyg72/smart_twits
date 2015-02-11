# require 'rubygems'
require 'twitter'
require 'byebug'
require 'rest-client'
require 'json'
require 'open-uri'

PATH = './credentials.md'
LONDON = 44418
PATH_TRENDS = './data/trends/'
PATH_TWEETS = './data/tweets/'
PATH_TWEETS_TEXT = './data/tweets/text/'
PATH_TWEETS_FOLLOWERS = './data/tweets/followers/'
PATH_TWEETS_RETWEETED = './data/tweets/retweeted/'

class APITwitter

  attr_reader :client, :trends

  def initialize
    hash_with_passes = load_passes
    @client = init_twit(hash_with_passes)
    @trends = []
  end

  def load_passes(path = PATH)
    return Hash[*File.read(path).split(/[: \n]+/)]
  end

  def init_twit(hash_with_keys)
    # byebug
    Twitter::REST::Client.new do |config|
      config.consumer_key        = hash_with_keys["Consumer_Key(API_Key)"]
      config.consumer_secret     = hash_with_keys["Consumer_Secret(API_Secret)"]
      config.access_token        = hash_with_keys["Access_Token"]
      config.access_token_secret = hash_with_keys["Access_Token_Secret"]
    end
  end

  def save_data(filename,item)
    file = File.open(filename, 'w')
    file.puts item
    file.close()  
  end

  def get_trends(id_g = LONDON)
    @response = @client.trends(id=id_g)
    @response.attrs[:trends].each { |el| @trends << {:name => el[:name],:query => el[:query]}}
    save_data(PATH_TRENDS+'toptrends.txt',@trends) #maybe @trends does not need to be
    @response                          #instance ver. 
  end

  def save_tweets_per_trend(query_number = 100,trends = @trends)
    trends.each do |trend| 
      tweets = get_tweets(trend[:query],query_number)
      save_data(PATH_TWEETS+trend[:name]+'_tweets.txt',tweets)
    end
  end

  def get_tweets(hash_tag_g,query_number = 10)
    tweets = @client.search(hash_tag_g).take(query_number)
    result=[]
    tweets.each do |el|
      result << {:text => el.text, :followers => el.user.followers_count,
                 :user_id => el.user.id, :retweet => el.retweet_count}
    end
    # save_data(hash_tag_g+'_tweets.dat',result)
    return result
  end

  def getlocation
     html = open('https://twitter.com/trends?id=44418').read
  end

  def merge_tweets(array_of_hash)
    array_of_hash.reduce('') {|sum, el| sum += el[:text]}
  end

  def save_tweet_text(tweet_text_string, trend)
    filename = trend+'_text.txt'
    file = File.open(filename, 'w')
    file.puts tweet_text_string
    file.close()
  end

  def top_followers_tweets(array_of_hashes, number = 5)
    array_of_hashes.sort { |x, y| x[:followers] <=> y[:followers] }.reverse[0..(number-1)]
  end

  def top_retweeted_tweets(array_of_hashes, number = 5)
    array_of_hashes.sort { |x, y| x[:retweet] <=> y[:retweet] }.reverse[0..(number-1)]
  end

  def get_tweet_from_file (filename)

    array_of_hashes = []
    file = File.open(filename, 'r')
    file.readlines.each do |el| 
      array_of_hashes << eval(el.chomp)
    end
    file.close()
    return array_of_hashes
  end

  def save_tweet_text_per_trend(trends = @trends)
    trends.each do |trend| 
      tweets = get_tweet_from_file(PATH_TWEETS+trend[:name]+'_tweets.txt')
      tweet_text = merge_tweets(tweets)
      save_data(PATH_TWEETS_TEXT+trend[:name]+'_tweets_text.txt', tweet_text)
    end
  end

  def save_tweets_most_followers_per_trend(trends = @trends)
    trends.each do |trend| 
      tweets = get_tweet_from_file(PATH_TWEETS+trend[:name]+'_tweets.txt')
      tweets_most_followers = top_followers_tweets(tweets)
      save_data(PATH_TWEETS_FOLLOWERS+trend[:name]+'_tweets_followers.txt', tweets_most_followers)
    end
  end  

  def save_tweets_most_retweeted_per_trend(trends = @trends)
    trends.each do |trend| 
      tweets = get_tweet_from_file(PATH_TWEETS+trend[:name]+'_tweets.txt')
      tweets_most_retweeted = top_retweeted_tweets(tweets)
      save_data(PATH_TWEETS_RETWEETED+trend[:name]+'_tweets_retweeted.txt', tweets_most_retweeted)
    end
  end  
  
end




