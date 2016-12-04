require_relative 'team'
require_relative 'scheduler'
require 'byebug'

##DEFINE RATINGS CONSTANTS
G5_RATINGS = File.readlines('g5_ratings.txt').map(&:to_f).freeze
RATINGS = File.readlines('p5_ratings.txt').map(&:to_f).freeze

##Assign ratings to teams
def assign_ratings(teams = Team.create_all)
  teams.shuffle.each_with_index do |team, idx|
    team.rating = RATINGS[idx]
    team.true_rank = idx + 1
  end

  teams
end

def new_conference_hash(teams)
  conferences = Hash.new { Array.new }

  teams.each do |team|
    conferences[team.conference] += [team]
  end

  conferences
end

def new_division_hash(teams)
  divisions = Hash.new { Array.new }

  teams.each do |team|
    string = "#{team.conference} #{team.division}"
    divisions[string] += [team]
  end
  divisions
end

##Run G5 games
  # TEAMS.each do |team|
  #   2.times do
  #     opp_rating = G5_RATINGS.sample
  #     sim_game(team, opponent)
  #   end
  # end

##Generate P5 Matchups, Run

##Generate conference game list, Run

##Play all games


### HELPER METHODS


##Game simulator
def sim_game(home, away)
  #Placeholder code that assigns winner by coin flip
  winner = rand(2) == 1 ? home : away
  loser = winner == home ? away : home

  if away.is_a?(Team)
    if winner.conference == loser.conference
      winner.add_conference_win
      loser.add_conference_loss
    else
      winner.add_win
      loser.add_loss
    end
  else
    winner == home ? winner.add_win : loser.add_loss
  end

  puts "#{winner} over #{loser}"

  #Determine winner
    #Norm Dist (home_rating + 3 - away_rating, STDDEV)
    #If rand(x) > y, home, away
  #Update W-L
    # if conference
    #   winner.add_conference_win
    #   loser.add_conference_loss
    # else
    #   winner.add_win
    #   loser.add_loss
    winner
end

def run_season(teams = Team.create_all)
  assign_ratings(teams)
  5.times do
    sample = teams.sample
    puts "#{sample}: #{sample.rating}"
  end
  games = generate_full_schedule(teams)

  games.shuffle.each { |game| sim_game(game[0], game[1]) }

  render_standings(teams)

  champ_games = get_championship_games(teams)

  champ_games.each { |_, game| champ_sim(game[0], game[1]) }

  playoff_teams = get_playoff_teams(teams)

  playoff_matchups = [
    [playoff_teams[0], playoff_teams[3]],
    [playoff_teams[1], playoff_teams[2]]
  ]

  national_championship = []

  playoff_matchups.each do |game|
    national_championship << sim_game(game[0], game[1])
  end

  champion = sim_game(national_championship[0], national_championship[1])

  puts "#{champion} wins the national championship!"
end

def ranker(teams)
  teams.sort { |x, y| [x.losses, y.conf_champ, y.wins] <=> [y.losses, x.conf_champ, x.wins] }
end

def get_championship_games(teams)
  division_hash = new_division_hash(teams)
  championship_games = Hash.new { Array.new }

  division_hash.each do |division, members|
    ranked = members.shuffle.sort { |x, y| [x.conf_losses, x.losses] <=> [y.conf_losses, y.losses] }
    division_champ = ranked[0]
    division_champ.div_winner += 1
    if division == "Big_12 "
      division_champ.conf_champ += 1
      next
    else
      championship_games[division_champ.conference] += [division_champ]
    end
  end

  championship_games.each do |conf, matchup|
    next if conf == :Big_12
    puts "#{conf} Championship Game: #{matchup[0]} (#{matchup[0].overall_record}) vs. #{matchup[1]} (#{matchup[1].overall_record})"
  end

  championship_games
end

def champ_sim(team1, team2)
  champ = sim_game(team1, team2)
  puts "#{champ} wins their conference championship!"
  champ.conf_champ += 1
end

def get_playoff_teams(teams, spots = 4)
  ranked = ranker(teams)
  ranked_list(ranked, 25)
  ranked.take(spots)
end

def ranked_list(ranked, num)
  puts "Top #{num}"
  num.times do |i|
    sample = ranked[i]
    puts "\##{i + 1} #{sample.name} #{sample.wins}-#{sample.losses} (#{sample.conf_wins}-#{sample.conf_losses})"
  end
end

def render_standings(teams)
  division_hash = new_division_hash(teams)

  division_hash.each do |division, members|
    ranked = members.shuffle.sort { |x, y| [x.conf_losses, x.losses] <=> [y.conf_losses, y.losses] }
    puts "#{division} Standings"
    ranked.each_with_index do |team, idx|
      puts "#{idx + 1}. #{team.conference_record} #{team.overall_record} #{team}"
    end
  end
end

if __FILE__ == $0
  teams = Team.create_all
  run_season(teams)
  # 5.times do
  #   sample = teams.sample
  #   puts "#{sample.name}: #{sample.wins}-#{sample.losses} (#{sample.conf_wins}-#{sample.conf_losses})"
  # end

  #get_championship_games(teams)

end
