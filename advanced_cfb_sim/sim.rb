require_relative 'team'
require_relative 'scheduler'
require_relative 'season'
require 'byebug'
require 'rubystats'

##DEFINE RATINGS CONSTANTS
G5_RATINGS = File.readlines('g5_ratings.txt').map(&:to_f).freeze
RATINGS = File.readlines('p5_ratings.txt').map(&:to_f).freeze

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

def get_sims(playoff_size, num)
  sims = Array.new
  num.times do
    new_season = Season.new(playoff_size)
    new_season.run
    sims << new_season
  end

  sims
end

def champ_counts(sims, rank)
  sims.map { |season| season.champion.true_rank }.count(rank)
end

def best_qualifed_counts(sims)
  sims.count { |season| season.best_qualified? }
end

def average_champ_rank(sims)
  sims.inject(0) { |acc, season| acc + season.champion.true_rank } / sims.size.to_f
end

def print_key_metrics(sims)
  n = sims.size

  successes = 0
  selected = 0
  champ_ranks = 0
  champ_game_ranks = 0.0
  championship_spreads = 0
  rank_harmonic_means = 0.0
  rating_harmonic_means = 0.0
  champ_counts = Hash.new(0)
  standard_playoff = Array.new(sims.first.playoff_size, 0)
  standard_champ = Array.new(2, 0)

  sims.each do |season|
    successes += 1 if season.champion.true_rank == 1
    selected += 1 if season.best_qualified?
    champ_ranks += season.champion.true_rank
    champ_game_ranks += season.championship_teams_rank_avg
    championship_spreads += season.championship_spread
    rank_harmonic_means += season.championship_rankings_harmonic_mean
    rating_harmonic_means += season.championship_ratings_harmonic_mean
    champ_counts[season.champion.true_rank] += 1
    season.playoff_team_true_ranks.sort.each_with_index do |rank, idx|
      standard_playoff[idx] += rank
    end
    season.championship_participants.map(&:true_rank).sort.each_with_index do |rank, idx|
      standard_champ[idx] += rank
    end
  end


  other_top_ten = 0
  other_top_25 = 0
  weak_teams = 0

  champ_counts.each do |k, v|
    next unless k > 5
    if k <= 10
      other_top_ten += v
    elsif k <= 25
      other_top_25 += v
    else
      weak_teams += v
    end
  end



  puts "The best team wins #{(successes / n.to_f * 100).round(2)}% of the time."
  puts "The best team is selected for postseason #{(selected / n.to_f * 100).round(2)}% of the time."
  puts "The average champion's true rank is #{(champ_ranks / n.to_f).round(2)}"
  puts "The average championship game participant's true rank is #{(champ_game_ranks / n.to_f).round(2)}"
  puts "The average championship game spread is #{(championship_spreads / n.to_f).round(2)}"
  puts "The average harmoic mean of the championship game rankings is #{(rank_harmonic_means / n.to_f).round(2)}"
  puts "The average harmoic mean of the championship game ratings is #{(rating_harmonic_means / n.to_f).round(2)}"
  puts "True rank 2 won #{(champ_counts[2] * 100 / n.to_f).round(2)}% of the time."
  puts "True rank 3 won #{(champ_counts[3] * 100 / n.to_f).round(2)}% of the time."
  puts "True rank 4 won #{(champ_counts[4] * 100 / n.to_f).round(2)}% of the time."
  puts "True rank 5 won #{(champ_counts[5] * 100 / n.to_f).round(2)}% of the time."
  puts "Rest of top 10 won #{(other_top_ten * 100 / n.to_f).round(2)}% of the time."
  puts "Rest of top 25 won #{(other_top_25 * 100 / n.to_f).round(2)}% of the time."
  puts "Weak teams won #{(weak_teams * 100 / n.to_f).round(2)}% of the time."
  puts "The standard playoff year looked like: #{standard_playoff.map { |tot| (tot / n.to_f).round(2) } }"
  puts "The standard championship game looked like: #{standard_champ.map { |tot| (tot / n.to_f).round(2) } }"


  puts
end


if __FILE__ == $0
  num_sims = 100000

  sims = get_sims(2, num_sims)
  puts "In a single championship game format:"
  print_key_metrics(sims)

  # sims = get_sims(3, num_sims)
  # puts "In a three-team playoff format:"
  # print_key_metrics(sims)

  sims = get_sims(4, num_sims)
  puts "In a four-team playoff format:"
  print_key_metrics(sims)

  # sims = get_sims(5, num_sims)
  # puts "In a five-team playoff format:"
  # print_key_metrics(sims)

  sims = get_sims(6, num_sims)
  puts "In a six-team playoff format:"
  print_key_metrics(sims)

  sims = get_sims(8, num_sims)
  puts "In an eight-team playoff format:"
  print_key_metrics(sims)

  # sims = get_sims(10, num_sims)
  # puts "In a ten-team playoff format:"
  # print_key_metrics(sims)

  sims = get_sims(12, num_sims)
  puts "In a twelve-team playoff format:"
  print_key_metrics(sims)
  #
  # sims = get_sims(14, num_sims)
  # puts "In a fourteen-team playoff format:"
  # print_key_metrics(sims)

  sims = get_sims(16, num_sims)
  puts "In a sixteen-team playoff format:"
  print_key_metrics(sims)

  # two_team_sims = []
  # 1000.times do
  #   new_season = Season.new(2)
  #   new_season.run
  #   two_team_sims << new_season
  # end
  #
  # four = []
  # 1000.times do
  #   new_season = Season.new(2)
  #   new_season.run
  #   two_team_sims << new_season
  # end
  # best_team_wins = 0
  # best_made_playoffs = 0
  # undefeateds = 0
  # conferences_represented = 0
  # all_different = 0
  # 1000000.times do
  #   teams = Team.create_all
  #   results = run_season(teams)
  #   best_team_wins += 1 if results[0].true_rank == 1
  #   best_made_playoffs += 1 if results[1]
  #   undefeateds += results[2]
  #   conferences_represented += results[3]
  #   all_different += 1 if results[4]
  # end
  #
  # puts "Best team won #{best_team_wins} times out of a million."
  # puts "Best team made playoffs #{best_made_playoffs} times."
  # puts "There were an average of #{undefeateds / 1000000.0} undefeated regular season teams."
  # puts "There were an average of #{conferences_represented / 1000000.0} conferences in the playoffs."
  # puts "Four different conferences were represented #{all_different} times."
  # 5.times do
  #   sample = teams.sample
  #   puts "#{sample.name}: #{sample.wins}-#{sample.losses} (#{sample.conf_wins}-#{sample.conf_losses})"
  # end

  #get_championship_games(teams)

end
