require 'gosu'
require 'yaml'
undef y
require './animation'

class GameObject
  
  attr_accessor :name, :state, :game
  
  def initialize(game_obj, name, dirname=nil)
    @game = game_obj
    @name = name
    @dx = @dy = @new_x = @new_y = nil
    @speed = 5.0
    @showing = @moving = false
    @animations = {}
    @images = {}
    @current_animation = nil
    @notify_when_done = nil
    reload(dirname)
  end
  
  def method_missing(meth_name, *args, &block)
    meth_name = meth_name.to_s
    if (meth_name[-1] == "=")
      # strip off the = from meth_name and set the state of it
      set_state(meth_name[0..-2], args.first)
    else
      val = get_state(meth_name) || nil
      if (!!Float(val) rescue false)
        val.to_f
      else
        val
      end
    end
  end
  
  def show?
    @showing
  end
  
  def show
    @showing = true
  end
  
  def hide
    @showing = false
  end
  
  def width
    if current_image
      current_image.width
    else
      0
    end
  end
  
  def height
    if current_image
      current_image.height
    else
      0
    end
  end
  
  def current_image
    @current_animation ? @current_animation.image : @images[get_state("current_image")]
  end
  
  def draw
    current_image.draw((x || 0.0), (y || 0.0), (z || 0.0)) if current_image
  end
  
  def move(new_x, new_y, notification=nil)
    @new_x = new_x
    @new_y = new_y
    dist = Gosu::distance((x || 0.0), (y || 0.0), @new_x, @new_y)
    #slope = (@y - @new_y) / (@x - @new_x)
    @dx = (@new_x - (x || 0.0)) / dist
    @dy = (@new_y - (y || 0.0)) / dist
    
    @notify_when_done = notification
    @moving = true
  end
  
  def tick
    if @moving
      if (Gosu::distance((x || 0.0), (y || 0.0), @new_x, @new_y) < @speed)
        self.x = @new_x
        self.y = @new_y
        @new_x = @new_y = @dx = @dy = nil
        @moving = false
        if (@notify_when_done)
          @notify_when_done.trigger
        end
      else
        self.x = (x || 0.0) + (@dx * @speed)
        self.y = (y || 0.0) + (@dy * @speed)
      end
    end
    
    if (@current_animation)
      @current_animation.tick
    end
  end
  
  def start_animation(ani_name)
    puts "starting animation: #{@animations[ani_name]}"
    @current_animation = @animations[ani_name]
  end
  
  def stop_animation
    puts "stopping animation: #{@current_animation}"
    @current_animation.reset if @current_animation
    @current_animation = nil
  end
  
  def set_image(img_name)
    puts "setting image to: #{img_name}"
    set_state("current_image", img_name)
  end
  
  def images
    @images
  end
  
  def reload(dirname=nil)
    load_media(dirname)
    load_logic(dirname)
  end
  
  def load_media(dirname=nil)
    dirname = "./data/game_objects/#{@name}" unless dirname
    
    if (File.exists?("#{dirname}/animations"))
      Dir.foreach("#{dirname}/animations") do |ani_dir|
        if (File.directory?("#{dirname}/animations/#{ani_dir}") && ani_dir != "." && ani_dir != ".." && ani_dir != ".DS_Store")
          ani = Animation.new()
          Dir.foreach("#{dirname}/animations/#{ani_dir}") do |filename|
            puts "loading animation #{dirname}/animations/#{ani_dir}"
            if (filename != "." && filename != ".." && filename != ".DS_Store" && filename != "config.yml")
              ani << Gosu::Image.new(game.window, "#{dirname}/animations/#{ani_dir}/#{filename}", false)
            end
            if (filename == "config.yml")
              cfg = YAML::load(File.read("#{dirname}/animations/#{ani_dir}/config.yml"))
              if (cfg.is_a?(Hash))
                ani.speed = cfg["speed"]
              end
            end
          end
          @animations[ani_dir] = ani
        end
      end
    end
    
    if (File.exists?("#{dirname}/images"))
      Dir.foreach("#{dirname}/images") do |image_file|
        if (image_file != "." && image_file != ".." && image_file != ".DS_Store")
          puts "loading image #{dirname}/images/#{image_file}"
          @images[image_file] = Gosu::Image.new(game.window, "#{dirname}/images/#{image_file}", false)
        end
      end
    end
    
    if (File.exists?("#{dirname}/config.yml"))
      cfg = YAML::load(File.read("#{dirname}/config.yml"))
      @speed = cfg["speed"] if cfg && cfg["speed"]
      @current_img = cfg["initial_image"] if cfg && cfg["initial_image"]
    end
    
  end
  
  def load_logic(dirname=nil)
    # first require anything under data/game_objects/#{@name}/logic.rb
    begin
      dirname ||= @name
      load("./data/game_objects/#{dirname}/logic.rb")
      self.extend(Kernel.const_get(@name))
    rescue Exception
    end
    
    @state = game.state[self.name]
    
  end
  
  def current_area=(area_name)
    move_to(area_name)
  end
  
  def move_to(area_name, x=nil, y=nil)
    set_state("current_area", area_name)
    game.move_object(self.name, area_name, x, y)
  end
  
  def init
    
  end
  
  def on_click(mouse_x, mouse_y)
    game.do_player_move(self.x + examine_from_xy.first, self.y + examine_from_xy.last, ["game_objects['#{self.name}'].on_examine()"])
  end
  
  def on_examine()
    game.do_dialog(dialogs()[get_state("next_dialog")])
  end
  
  def enter_coordinates(from_area, to_area)
    game.enter_coordinates(from_area, to_area)
  end
  
  def warp
    
  end
  
  def examine_from_xy()
    [0, 0]
  end
  
  def dialogs()
    {}
  end
  
  def get_state(state_name_or_obj_name, state_name=nil)
    if state_name
      @game.get_state(state_name_or_obj_name, state_name)
    else
      @game.get_state(self.name, state_name_or_obj_name)
    end
  end
  
  def set_state(object_name_or_state_name, state_name_or_value, value=nil)
    if (value)
      @game.set_state(object_name_or_state_name, state_name_or_value, value)
    else
      @game.set_state(self.name, object_name_or_state_name, state_name_or_value)
    end
  end
  
  def respond_to_notification(message, params=nil)
    puts "responding to notification: #{message}"
    if (params && params.is_a?(Array))
      params.each do |p|
        self.instance_eval(p)
      end
    end
  end
  
end

# go = GameObject.new(Gosu::Window.new(640, 480, false), "main_guy")
