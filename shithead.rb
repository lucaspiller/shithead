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

  attr_accessor :rank, :suit, :id

  def initialize(id)
    self.id = id
    self.rank = RANKS[id % 13]
    self.suit = SUITS[(id / 13).floor]
  end

  def to_s
    "#{self.rank} of #{self.suit}s"
  end

  def <=>(other)
    self.id <=> other.id
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

  def initialize
    self.face_down_cards = []
    self.face_up_cards = []
    self.hand_cards = []
  def initialize(name)
    self.name = name
    self.face_down_cards = Hand.new
    self.face_up_cards = Hand.new
    self.hand_cards = Hand.new
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
      if self.last.rank > card.rank
        raise IllegalMoveException.new("Can't play #{card} on #{self.last}")
      end
    end

    super(card)
  end
end

class Game
  attr_accessor :players, :deck, :pile

  def initialize(players, decks = 1)
    self.deck = Deck.new * decks
    self.deck.shuffle!
    self.pile = Pile.new

    self.players = []
    players.times do
      self.players << Player.new
    end

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
