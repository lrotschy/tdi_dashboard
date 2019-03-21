require "yaml"

data = {
  "fake_workshop_1" => { "Values" => {
                          "Values are unnatural" => {
                            "pre" => { "P1" => 2, "P2" => 3, "P3" => 5, "P4" => 1, "P5" => 4},
                            "post" => { "P1" => 2, "P2" => 3, "P3" => 5, "P4" => 1, "P5" => 4} },
                          "Values are overrated"=> {
                            "pre" => { "P1" => 2, "P2" => 3, "P3" => 5, "P4" => 1, "P5" => 4},
                            "post" => { "P1" => 2, "P2" => 3, "P3" => 5, "P4" => 1, "P5" => 4} }
                        },
                      "Reality" => {
                              "Reality isn't real" => {
                                  "pre" => { "P1" => 2, "P2" => 3, "P3" => 5, "P4" => 1, "P5" => 4},
                                  "post" => { "P1" => 2, "P2" => 3, "P3" => 5, "P4" => 1, "P5" => 4} },
                              "Science is fake"=> {
                                  "pre" => { "P1" => 2, "P2" => 3, "P3" => 5, "P4" => 1, "P5" => 4},
                                  "post" => { "P1" => 2, "P2" => 3, "P3" => 5, "P4" => 1, "P5" => 4}}
                                }
                        },
    "fake_workshop_2" => { "Values" => {
                            "Values are unnatural" => {
                                "pre" => { "P1" => 1, "P2" => 2, "P3" => 2, "P4" => 1, "P5" => 2},
                                "post" => { "P1" => 4, "P2" => 3, "P3" => 5, "P4" => 1, "P5" => 4}
                              },
                            "Values are overrated"=> {
                                "pre" => { "P1" => 2, "P2" => 3, "P3" => 3, "P4" => 3, "P5" => 4},
                                "post" => { "P1" => 5, "P2" => 5, "P3" => 5, "P4" => 5, "P5" => 5}}
                          },
                          "Reality" => {
                              "Reality isn't real" => {
                                "pre" => { "P1" => 1, "P2" => 5, "P3" => 5, "P4" => 1, "P5" => 5},
                                "post" => { "P1" => 2, "P2" => 3, "P3" => 5, "P4" => 1, "P5" => 4}},
                              "Science is fake"=> {
                                "pre" => { "P1" => 2, "P2" => 3, "P3" => 4, "P4" => 3, "P5" => 4},
                                "post" => { "P1" => 1, "P2" => 1, "P3" => 1, "P4" => 1, "P5" => 4}}
                            }
                    }
    }

File.open("data.yaml", "w") { |file| file.write(data.to_yaml) }
