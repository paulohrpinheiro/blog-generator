require 'date'
require_relative 'render'

module GeraBlog
  # Blog
  class Blog
    attr_reader :root_dir,:output_dir, :texts_dir, :template_dir
    attr_reader :title, :name, :description
    attr_reader :template, :posts

    @posts = []

    def initialize(
      root_dir: './',
      title: 'GeraBlog',
      name: 'GeraBlog Static Blog Generator',
      description: 'Blog Generator - my own static site generator'
    )

      @root_dir = root_dir
      @title = title
      @name = name
      @description = description
      @output_dir = File.join(@root_dir, 'output')
      @texts_dir = File.join(@root_dir, 'texts')
      @template_dir = File.join(@root_dir, 'templates')
      @template = {
        categories: File.join(@template_dir, 'categories.html.erb'),
        feed: File.join(@template_dir, 'feed.xml.erb'),
        post: File.join(@template_dir, 'post.html.erb')
      }

    end

    def save
      Dir.mkdir(@output_dir) unless Dir.exist?(@output_dir)

      @posts.map { |p| p[:category] }.uniq.each do |category|
        category_dir = File.join(@output_dir, category)
        image_src = File.join @root_dir, 'texts', category, 'images'

        Dir.mkdir(category_dir) unless Dir.exist?(category_dir)

        FileUtils.cp_r(
          image_src,
          File.join(category_dir, 'images')
        ) if Dir.exist?(image_src)
      end

      @posts.map { |post| File.write(post[:filename], post[:content]) }
    end

    def render!
      @posts = render
    end

    def render
      posts = []

      Dir[File.join(@texts_dir, '*')].each do |category_dir|
        category = File.basename category_dir
        Dir["#{category_dir}/*.md"]
          .sort
          .reverse
          .map { |f| posts.push render_page(filename: f, category: category) }
      end

      posts
    end

    def render_page(filename:, category:)
      md_content = File.read(filename)
      lines = md_content.split("\n")
      newfile = File.basename(filename).sub(%r{md$}, 'html')

      post = {
        title: lines[0][2..-1],
        category: category,
        description: lines[2][3..-1],
        date: Date.parse(newfile.match('\A(....-..-..)')[1]).rfc822,
        content: md_content,
        filename: File.join(@output_dir, category, newfile)
      }

      post[:content] = GeraBlog::Render
        .new(lang: category, blog: self)
        .to_html(post: post)

      post
    end
  end
end
