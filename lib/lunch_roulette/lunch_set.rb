class LunchRoulette
  class LunchSet

    MIN_GROUP_SIZE = Config.config[:min_group_size]

    attr_accessor :id, :groups

    def initialize(id:, groups:)
      @id = id
      @groups = groups
    end

    def self.generate(people)
      set_id = people.flat_map(&:lunches).map(&:set_id).max.to_i + 1
      groups = generate_groups(set_id: set_id, people: people)
      new(id: set_id, groups: groups)
    end

    def self.generate_groups(set_id:, people:)
      group_count = people.length / MIN_GROUP_SIZE
      groups = []
      people.each_with_index do |person, i|
        group_index = i % group_count
        groups[group_index] = Array(groups[group_index]) << person
      end
      groups.map.with_index do |g, i| 
        LunchGroup.new(
          id: i + 1,
          people: g.map{|p| p.add_lunch(Lunch.new(set_id: set_id, group_id: i + 1))}
        )
      end
    end

    def people
      @people ||= groups.flat_map(&:people)
    end

    def score
      @score ||= groups.map(&:score).sum
    end

    def valid?
      @valid ||= groups.map(&:valid?).all?
    end

    def inspect_previous_groups
      groups.map do |g| 
        previous_groups = g.inspect_previous_groups
        if previous_groups.empty?
          "🐣  #{g.inspect}\n   No prior shared lunches!"
        else
          "🥚  #{g.inspect}\n   #{previous_groups.length} prior#{'s' unless previous_groups.length == 1}: " + 
          previous_groups.join(', ')
        end
      end.join("\n")
    end

    def inspect_scores
      ["Overall score #{score.round(3)}", groups.map(&:inspect_scores)].join("\n")
    end

    def inspect_emails
      groups.map(&:inspect_emails).join("\n")
    end
  end
end
