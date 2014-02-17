# coding: utf-8

class ApiResponses
  def self.followed_accts
    return [

    {:id=>564919357,
        :id_str=>"564919357",
        :name=>"I Am Devloper",
        :screen_name=>"iamdevloper",
        :location=>"Localhost",
        :description=> "These views are also the opinions of my employers, any problems, speak to their legal team. *puts headphones back in*",
        :url=>"http://t.co/Hcd0PBjb",
    },

    {:id=>56956664,
      :id_str=>"56956664",
      :name=>"JavaScriptMVC",
      :screen_name=>"javascriptmvc",
      :location=>"Chicago",
      :description=>"Open Source, Maintainable JavaScript library.",
      :url=>"http://t.co/b51ULImYy7",
    },

    {:id=>589215872,
      :id_str=>"589215872",
      :name=>"jQuery++",
      :screen_name=>"jquerypp",
      :location=>"Chicago",
      :description=> "I am a collection of useful jQuery extensions and special events by @bitovi and the JS community.",
      :url=>"http://t.co/GQJlLmNBya",
    },

    {:id=>523041627,
      :id_str=>"523041627",
      :name=>"CanJS",
      :screen_name=>"canjs",
      :location=>"Chicago",
      :description=> "The safer, faster, easier, smaller, library-er JS MVC library. By @bitovi and the JS community.",
      :url=>"http://t.co/XRm9p6Wi28",
    },

    {:id=>123763453,
      :id_str=>"123763453",
      :name=>"Bitovi",
      :screen_name=>"bitovi",
      :location=>"Chicago",
      :description=>"JavaScript Consulting, Training, Open Source, UX & UI Design",
      :url=>"http://t.co/jXG4s6Bsa3",
    }]

  end

  def self.watched_repos
    return [

    {"id"=>1816059,
      "name"=>"bius_infosystem",
      "full_name"=>"neektza/bius_infosystem"},
    {"id"=>5688547,
      "name"=>"communityjmvc",
      "full_name"=>"jupiterjs/communityjmvc"},
    {"id"=>5892131,
      "name"=>"jquerypp",
      "full_name"=>"bitovi/jquerypp"},
    {"id"=>5892166,
      "name"=>"crawler",
      "full_name"=>"jupiterjs/crawler"},
    {"id"=>5952100,
      "name"=>"canjs",
      "full_name"=>"bitovi/canjs"},
    {"id"=>5990381,
      "name"=>"javascriptmvc",
      "full_name"=>"bitovi/javascriptmvc"},
    {"id"=>6035295,
      "name"=>"feeder-tagger",
      "full_name"=>"jupiterjs/feeder-tagger"},
    {"id"=>8780874,
      "name"=>"bithub",
      "full_name"=>"bitovi/bithub"},
    {"id"=>9013472,
      "name"=>"bithub-tagger",
      "full_name"=>"bitovi/bithub-tagger"},
    {"id"=>9013504,
      "name"=>"bithub-crawler",
      "full_name"=>"bitovi/bithub-crawler"},
    {"id"=>9059614,
      "name"=>"bithub-client",
      "full_name"=>"bitovi/bithub-client"},
    ] 
  end
end
