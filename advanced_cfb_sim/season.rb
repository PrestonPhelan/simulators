require_relative 'sim'
require_relative 'scheduler'
require 'rubystats'
require 'byebug'

class Season
  attr_reader :champion, :undefeateds, :playoff_teams

  def initialize(playoff_size = 4)
    @teams = Team.create_all
    @conference_hash = new_conference_hash(@teams)
    @division_hash = new_division_hash(@teams)
    @playoff_size = playoff_size
  end

  def assign_ratings
    @teams.shuffle.each_with_index do |team, idx|
      team.rating = RATINGS[idx]
      team.true_rank = idx + 1
    end

    @teams
  end


  def ranker
    @teams.shuffle.sort do |x, y|
      [x.losses, y.conf_champ, y.wins] <=>
      [y.losses, x.conf_champ, x.wins]
    end
  end

  def render_ranked_list(num = 25)
    ranked = ranker
    puts "Top #{num}"
    num.times do |i|
      team = ranked[i]
      puts "\##{i + 1} (#{team.true_rank}) #{team.name} #{team.overall_record} (#{team.conference_record})"
    end
    nil
  end

  def render_standings
    @division_hash.each do |division, members|
      ranked = members.shuffle.sort do |x, y|
        [x.conf_losses, x.losses] <=> [y.conf_losses, y.losses]
      end

      puts "#{division} Standings"
      ranked.each_with_index do |team, idx|
        puts "#{idx + 1}. #{team.conference_record} #{team.overall_record} #{team}"
      end
    end

    nil
  end

  def run
    assign_ratings

    games = generate_full_schedule(@teams)

    games.each { |game| sim_game(game) }

    championship_games.each { |_, game| champ_sim(game) }

    @undefeateds = undefeated_count

    #debugger

    @playoff_teams = get_playoff_teams

    @champion = run_playoffs(@playoff_teams)
  end

  def sim_game(matchup, neutral = false)
    home = matchup[0]
    away = matchup[1]

    return home if away == "Bye"
    return away if home == "Bye"

    away_rating = away.is_a?(Team) ? away.rating : away

    game_mean = home.rating - away_rating
    game_mean += 3 unless neutral
    gen = Rubystats::NormalDistribution.new(game_mean, 13)
    result = gen.rng

    winner = result > 0 ? home : away
    loser = winner == home ? away : home

    if away.is_a?(Team)
      update_record(winner, loser)
    else
      winner == home ? winner.add_win : loser.add_loss
    end
    #puts "#{winner} over #{loser} by #{result.to_i}"
    winner
  end

  def update_record(winner, loser)
    if winner.conference == loser.conference
      winner.add_conference_win
      loser.add_conference_loss
    else
      winner.add_win
      loser.add_loss
    end
  end

  def champ_sim(game)
    champ = sim_game(game, true)
    #puts "#{champ} wins their conference championship!"
    champ.conf_champ += 1
  end

  def championship_games
    championship_games = Hash.new { Array.new }

    @division_hash.each do |division, members|
      ranked = members.shuffle.sort do |x, y|
        [x.conf_losses, x.losses] <=> [y.conf_losses, y.losses]
      end
      division_champ = ranked[0]
      division_champ.div_winner += 1
      if division == "Big_12 "
        division_champ.conf_champ += 1
        next
      else
        championship_games[division_champ.conference] += [division_champ]
      end
    end

    # championship_games.each do |conf, matchup|
    #   next if conf == :Big_12
    #   #puts "#{conf} Championship Game: #{matchup[0]} (#{matchup[0].overall_record}) vs. #{matchup[1]} (#{matchup[1].overall_record})"
    # end

    championship_games
  end

  POWERS_OF_TWO = [1, 2, 4, 8, 16, 32, 64, 128].freeze
  def get_playoff_teams
    #Matchups must return in correct playoff tree order.

    qualifiers = ranker.take(@playoff_size)
    qualifiers.each { |team| team.playoff_team = true }
    until POWERS_OF_TWO.include?(qualifiers.size)
      qualifiers << "Bye"
    end

    ordered = [qualifiers.first]
    until ordered.size == qualifiers.size
      new_ordered = Array.new
      ordered.each do |team|
        rank = qualifiers.find_index(team) + 1
        opp_rnk = ordered.size * 2 - rank
        new_ordered << team
        new_ordered << qualifiers[opp_rnk]
      end
      ordered = new_ordered
    end
    ordered_teams = ordered.uniq
    ordered_teams.delete("Bye")
    raise unless ordered_teams.size == @playoff_size
    ordered
  end

  def run_playoffs(playoff_teams)
    if playoff_teams.size == 2
      @championship_participants = playoff_teams
      return sim_game(playoff_teams)
    end
    winners = Array.new
    (playoff_teams.size / 2).times do |i|
      winners << sim_game(playoff_teams[i..i + 1], true)
    end

    run_playoffs(winners)
  end

  def playoff_team_true_ranks
    @playoff_teams.map(&:true_rank)
  end

  def undefeated_count
    @teams.count { |team| team.losses == 0 }
  end

  def best_qualified?
    @playoff_teams.each do |team|
      next unless team.is_a?(Team)
      return true if team.true_rank == 1
    end
    false
  end

  def championship_teams_rank_avg
    total = @championship_participants.inject(0) do |acc, team|
      acc + team.true_rank
    end

    total / 2.0
  end

  def championship_ratings_harmonic_mean
    Math.sqrt(@championship_participants[0].rating * @championship_participants[1].rating)
  end

  def championship_rankings_harmonic_mean
    Math.sqrt(@championship_participants[0].true_rank * @championship_participants[1].true_rank)
  end

  def championship_spread
    (@championship_participants[0].rating - @championship_participants[1].rating).abs
  end
end
