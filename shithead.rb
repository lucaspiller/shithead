class Card
  RANKS = %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace)
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
    (0..51).to_a.shuffle.each do |id|
      self << Card.new(id)
    end
  end
end

class Player
  attr_accessor :face_down_cards, :face_up_cards, :hand_cards

  def initialize
    self.face_down_cards = []
    self.face_up_cards = []
    self.hand_cards = []
  end
end

class Game
  attr_accessor :players, :deck

  def initialize(players)
    self.deck = Deck.new

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
