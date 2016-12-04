TEAMS = {
  ACC: {
    Atlantic: [
      "Clemson", "Louisville", "Florida State",
      "NC State", "Wake Forest", "Boston College", "Syracuse"
    ],
    Coastal: [
      "Virginia Tech", "North Carolina", "Miami", "Pittsburgh",
      "Georgia Tech", "Duke", "Virginia"
    ]
  },
  Big_12: [
    "Oklahoma", "West Virginia", "Oklahoma State", "Kansas State",
    "TCU", "Baylor", "Texas", "Texas Tech", "Iowa State", "Kansas"
  ],
  Big_Ten: {
    East: [
      "Ohio State", "Penn State", "Michigan", "Indiana", "Maryland",
      "Michigan State", "Rutgers"
    ],
    West: [
      "Purdue", "Northwestern", "Illinois", "Wisconsin", "Iowa",
      "Minnesota", "Nebraska"
    ]
  },
  PAC_12: {
    North: [
      "Washington", "Washington State", "Oregon", "Oregon State",
      "Stanford", "California"
    ],
    South: [
      "USC", "UCLA", "Arizona", "Arizona State", "Utah", "Colorado"
    ]
  },
  SEC: {
    East: [
      "Florida", "Georgia", "South Carolina", "Tennessee", "Kentucky",
      "Missouri", "Vanderbilt"
    ],
    West: [
      "Alabama", "Auburn", "Mississippi State", "Ole Miss", "LSU",
      "Texas A&M", "Arkansas"
    ]
  }
}.freeze

class Team
  attr_accessor :wins, :losses, :conf_wins, :conf_losses, :rating
  attr_reader :name, :conference, :division

  def self.create_all
    all_teams = []

    TEAMS.each do |conf, coll|
      if coll.is_a?(Hash)
        coll.each do |div, teams|
          teams.each do |team|
            all_teams << Team.new(team, conf, div)
          end
        end
      else
        coll.each do |team|
          all_teams << Team.new(team, conf)
        end
      end
    end

    all_teams
  end

  def initialize(name, conference, division = nil)
    @name = name
    @conference = conference
    @division = division
    @rating = nil
    @wins = 0
    @losses = 0
    @conf_wins = 0
    @conf_losses = 0
  end

  def add_win
    @wins += 1
  end

  def add_loss
    @losses += 1
  end

  def add_conference_win
    @wins += 1
    @conf_wins += 1
  end

  def add_conference_loss
    @losses += 1
    @conf_losses += 1
  end

  def to_s
    @name
  end
end
