class IllegalMoveException < Exception
end

class Rank < String
  def initialize(value)
    super(value.to_s)
  end

  def to_i
    case self
    when "Jack"
      11
    when "Queen"
      12
    when "King"
      13
    when "Ace"
      14
    else
      super
    end
  end

  def <=>(other)
    self.to_i <=> other.to_i
  end
end

class Card
  RANKS = %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace).collect { |r| Rank.new(r) }
  SUITS = %w(Spade Heart Club Diamond)
  MAGIC_RANKS = {
    2 => :reset,
    7 => :reverse,
    8 => :mirror,
    10 => :burn
  }

  attr_accessor :rank, :suit, :id

  def initialize(id)
    self.id = id
    self.rank = RANKS[id % 13]
    self.suit = SUITS[(id / 13).floor]
  end

  def to_s
    "#{self.rank} of #{self.suit}s" + (magic? ? " (#{magic?})" : "")
  end

  def <=>(other)
    self.id <=> other.id
  end

  def magic?(type = nil)
    if type
      MAGIC_RANKS[self.rank.to_i] == type
    else
      MAGIC_RANKS[self.rank.to_i] || false
    end
  end
end

class Deck < Array
  def initialize
    # shuffle array and init each Card
    (0..51).to_a.each do |id|
      self << Card.new(id)
    end
  end
end

class Player
  attr_accessor :face_down_cards, :face_up_cards, :hand_cards, :name

  def initialize(name)
    self.name = name
    self.face_down_cards = Hand.new
    self.face_up_cards = Hand.new
    self.hand_cards = Hand.new
  end

  def say(text)
    puts ">> #{name}: #{text}"
  end

  def to_s
    "#{name} Hand: #{self.hand_cards.size} Up: #{self.face_up_cards.size} Down: #{self.face_down_cards.size}"
  end
end

class AiPlayer < Player
  def play!(game)
    self.hand_cards.each_index do |index|
      card = self.hand_cards[index]
      begin
        game.pile << card
        self.hand_cards.delete_at(index)
        say "I played #{card}"
        pickup!(game)
        return
      rescue IllegalMoveException
        # try next card
      end
    end

    # can't play
    pickup_pile!(game)
  end

  def pickup_pile!(game)
    self.hand_cards.push *game.pile
    game.pile = Pile.new

    say "I picked up"
    play!(game)
  end

  def pickup!(game)
    return unless self.hand_cards.size < 3

    self.hand_cards << game.deck.pop
    return if self.hand_cards.size > 0

    self.hand_cards << self.face_up_cards.pop
    return if self.hand_cards.size > 0

    self.hand_cards << self.face_down_cards.pop
    return if self.hand_cards.size > 0

    raise RuntimeError.new("Player #{name} won")
  end
end

class Hand < Array
  def <<(card)
    return if card.nil?
    super(card)
  end
end

class Pile < Hand
  def <<(card)
    unless self.size == 0
      unless card_can_be_played?(card)
        raise IllegalMoveException.new("Can't play #{card} on #{self.last}")
      end
    end

    super(card)
  end

  def card_can_be_played?(card)
    last = self.last

    # Reset card and burn card can be played on anything
    return true if card.magic?(:reset)
    return true if card.magic?(:burn)

    # Check for prior mirror card
    last = self[self.size - 1] if last.magic?(:mirror)

    # Check for prior reverse card
    return card.rank <= last.rank if last.magic?(:reverse)

    # Otherwise standard ranking
    card.rank >= last.rank
  end

  def should_burn?
    # Shouldn't burn if empty
    return false if self.empty?

    # Burn if a 10 was played
    return true if self.last.magic?(:burn)

    # Shouldn't burn otherwise if less than 4 cards
    return false if self.size < 4

    # Burn if 4 consecutive ranking cards have been played
    return true if self.last(4).uniq.size == 1

    # Otherwise no
    false
  end
end

class Game
  attr_accessor :players, :deck, :pile

  def initialize(players, decks = 1)
    self.deck = Deck.new * decks
    self.deck.shuffle!
    self.pile = Pile.new

    self.players = players

    3.times do
      self.players.each do |player|
        player.face_down_cards << deck.pop
      end
    end

    3.times do
      self.players.each do |player|
        player.face_up_cards << deck.pop
      end
    end

    3.times do
      self.players.each do |player|
        player.hand_cards << deck.pop
      end
    end
  end
end

if $0 == __FILE__
  game = Game.new((1..4).to_a.collect { |i| AiPlayer.new(i.to_s) })
  round = 0

  loop do
    round += 1
    puts
    puts "*** ROUND #{round} ***"

    game.players.each do |player|
      puts
      begin
        player.play!(game)
        if game.pile.should_burn?
          game.pile = Pile.new
          puts "*** Pile burnt ***"
        end
      end while game.pile.size == 0
      puts player
    end

    puts
    puts "Pile: #{game.pile.size} card(s)"
    puts game.pile

    puts
    puts "Deck: #{game.deck.size} card(s)"
  end
end
