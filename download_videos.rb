require 'watir'
require 'pry'
require 'fileutils'

class DripsDownloader

  AFTER_DOWNLOAD = 30
  FURTHER = 30

  def initialize topic_id, total_pages
    @topic_id = topic_id
    @total_pages = total_pages
    @skip_to = ARGV[0].to_i
    @single_download = ARGV[1] == '-s' ? 'single_download' : ''
    @no_download = ARGV[2] == '-d' ? 'no_download' : ''
    @skip_to_page = ARGV[3].to_i
    @home_dir = "#{ENV['HOME']}/Downloads/DailyDrip/staging/"
    init_browser
  end

  def init_browser
    prefs = {
      download: {
        prompt_for_download: false,
        default_directory: @home_dir
      }
    }
    @browser = Watir::Browser.new(:chrome, options: {prefs: prefs})
  end

  def attempt_login
    puts "Loggin in..."

    configs = YAML.load_file('./creds.yml')
    email = configs['credentials']['email']
    pwd = configs['credentials']['pwd']
    login_url = "https://www.dailydrip.com/users/sign_in"

    @browser.goto login_url
    sleep 1
    @browser.text_field(:type,'email').set(email)
    sleep 1
    @browser.text_field(:type,'password').set(pwd)
    sleep 1
    @browser.form(:id, "login").submit
    sleep 3

    !@browser.div(:class => %w(flash flash-warning)).exists?
  end

  def download_vids
    1.upto(@total_pages) do |page_no|
      index = 1

      puts "Processing page #{page_no} -------------------------------"
      if page_no < @skip_to_page
        puts "Skipping page #{page_no}"
        next
      end

      @browser.goto url_by_topic page_no
      links = @browser.elements(:css => 'a.pure-u-1.item-link-container')

      links.each.with_index(1) do |link, index|
        # skip unless link.h2.exists?
        if skippable?(index, link, page_no)
          puts "Skipping video #{index}"
          next
        end

        process(link, index)
        exit if single_download?
      end

    end
  end

  def process(link, index)
    name_text = link.text.split("\n").first
    puts "Processing entry #{index}: #{name_text}"

    sleep 2
    link.click
    sleep 2
    contents_before = dir_contents

    if no_download?
      puts "File already exists so no download"
      newest_file = [File.basename(latest_entry)]
    else
      download_or_next
      contents_after = dir_contents
      newest_file = contents_after - contents_before
    end

    rename_file(name_text, newest_file)

    @browser.back
  end

  private

  def url_by_topic(page_no)
    "https://www.dailydrip.com/drips/search?availability=all&order=oldest&" \
      "page=#{page_no}&q=&topic_id=#{@topic_id}&user_id=6197&utf8=%E2%9C%93&watched=all"
  end

  def download_or_next
    download_btn = @browser.link(:class, %w(buttercup-button download-button))
    if download_btn.exists?
      puts "--> Downloading video"
      sleep 2
      download_btn.click
      sleep AFTER_DOWNLOAD
      sleep more_and_log if still_downloading?
    else
      puts "No video for this lesson"
      sleep 2
      return
    end
  end

  def rename_file(name_text, new_file)
    unless new_file.empty?
      nums = name_text[/\[.*?\]/].gsub(/\[|\]/, '')
      title = name_text[/\].*?\[/].gsub(/\[|\]/, '').strip
      name_parts = new_file.first.split('.')

      if name_parts[2].nil?
        new_file = new_file.first
      else
        new_file = "#{name_parts[0]}.#{name_parts[1]}.#{name_parts[2]}"
        new_file = "#{new_file}.mp4" unless new_file.split('.').include?("mp4")
      end

      name = "#{nums}-#{title}.mp4"
      name = name.tr(' ', '_')
      FileUtils.mv "#{@home_dir}#{new_file}", "#{@home_dir}#{name}"
    end
  end

  def more_and_log
    puts "Adding more time for download..."
    sleep FURTHER
  end

  def dir_contents
    Dir.entries @home_dir
  end

  def latest_entry
    Dir.glob("#{@home_dir}/*").max_by {|f| File.mtime(f)}
  end

  def skippable? index, link, page_no
    !link.h2.exists? || (index < @skip_to && page_no == @skip_to_page)
  end

  def single_download?
    @single_download == 'single_download'
  end

  def no_download?
    @no_download == 'no_download'
  end

  def still_downloading?
    latest_file_ext = latest_entry
    latest_file_ext = latest_file_ext.split('.').last unless latest_file_ext.nil?
    latest_file_ext == 'crdownload'
  end

end

topic_id = 16
total_pages = 1

downloader = DripsDownloader.new(topic_id, total_pages)
successful_login = downloader.attempt_login
sleep 5
successful_login ? downloader.download_vids : (puts "Login failed. Check creds.")

# Elixir - 1
# Rails - 15
# React - 17
# Sidekiq - 5
# Docker - 28
# Nginx = 29
# Kubernites - 27
# JS - 22
# Elm - 2
# HTML & CSS - 3
# Daily Topics 13
# Swift - 9
# Koala - topic 23
# Ember - 8
# Go - 24
# R - 12
# Electron - 16
