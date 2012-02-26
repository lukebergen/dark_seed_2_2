# the name of the module should exactly match the name of the objects folder

module FarmerJim
  
  # THIS IS THE OFFSET FROM THIS OBJECT'S X,Y THAT THE PLAYER WILL MOVE TO WHEN EXAMINED
  def examine_from_xy
    [self.width + 20, 20]
  end
  
  def dialogs
    # this method should return a hash of the form:
    # { dialog_name => {"text"=>"text of dialog", "audio"=>"name of audio file", "responses"=>[{"text" => "text of response", "audio" => "audio file for response", "actions" => ["code that gets evaluated after this response is made", "more code to execute"]}, {more responses}]} }
    # where if the responses array has only one response whose hash does not contain the key "text", it will just be one of those "there is no response, just hit enter to continue and do the actions".
    {
      "monolog one" => {
        "text" => "Line 1{NEWLINE}Line 2{NEWLINE}Line 3{NEWLINE}Line 4",
        "audio" => "audio file"
      },
      "first dialog" => {
        "text"      => "Hello main charactor. What are you doing?",
        "audio"     => "audio file",
        "responses" => [
          {
            "text"    => "Investigating my brothers death",
            "audio"   => "audio file",
            "actions" => ["set_state('#{self.name}', 'next dialog', 'why investigating')", "do_dialog('#{name}')"]
          },
          {
            "text"    => "Just visiting the ol' town",
            "audio"   => "audio file",
            #"actions" => ["set_state('#{self.name}', 'next dialog', 'why investigating')", "do_dialog('#{name}')"]
            "actions" => ["set_state('#{self.name}', 'next dialog', 'thats nice')", "do_dialog('#{name}')"]
          }
        ]
      },
      "why investigating" => {
        "text"      => "There's nothing here to investigate! Go away now!",
        "audio"     => "audio file",
        "responses" => [{"actions" => ["set_state('#{self.name}', 'next dialog', 'I told you')"]}]
      },
      "I told you" => {
        "text"      => "I told you there's nothing to investigate, now go away",
        "audio"     => "audio file",
        "responses" => [{"actions" => ["set_state('#{self.name}', 'next dialog', 'I told you')"]}]
      },
      "thats nice" => {
        "text"  => "Well that's nice. Maybe we'll see each other around again soon.{NEWLINE}I have to go now.  Bye",
        "audio" => "audio file",
        "responses" => [{"text"=>"Ok, nice seeing you again.", "audio" => "audio file", "actions" => ["set_state('#{self.name}', 'next dialog', 'have to go')"]}]
      },
      "have to go" => {
        "text"      => "Like I said, I have to be going.  Bye now",
        "audio"     => "audio file",
        "responses" => [{"actions" => ["set_state('#{self.name}', 'next dialog', 'have to go')"]}]
      }
    }
  end
  
  # def on_examine()
  #   # based on what the state is, (and even using the game's state for global variables and such)
  #   # do whatever needs to be done on this object being examined.
  #   puts "I'm #{name} and I just been probed"
  # end
  
end