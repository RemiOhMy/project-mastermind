module Common
  def prompt(*args)
    print(*args)
    gets.chomp
  end

  def clear
    if Gem.win_platform?
      system 'cls'
    else
      system 'clear'
    end
  end
end

class Mastermind
  include Common

  class PlayerGuesser
    include Common
    def initialize; end

    def make_guess
      loop do
        choice = (prompt 'Please enter your guess (4 digit code from 1-6): ').split('').map(&:to_i)

        if choice.length == 4 &&
           choice[0].between?(1, 6) && choice[1].between?(1, 6) && choice[2].between?(1, 6) && choice[3].between?(1, 6)
          return choice
        else
          clear
          puts 'Invalid choice!'
        end
      end
    end

    def generate_code
      new_code = []
      4.times do
        new_code.push(rand(1..6))
      end
      new_code
    end

    def game_winner(winner)
      if winner
        puts 'Player Wins'
      else
        puts 'Computer Wins'
      end
    end
  end

  class ComputerGuesser
    include Common
    attr_accessor :previous

    def initialize; end

    def make_guess
      new_guess = []

      if @previous.nil?
        new_guess = [1, 1, 1, 1]
      else
        4.times do |i|
          if @code[i] == @previous[i]
            new_guess.push(@code[i])
          else
            new_guess.push(rand(1..6))
          end
        end
      end

      @previous = new_guess

      new_guess
    end

    def generate_code
      loop do
        new_code = (prompt 'Please enter your secret code (4 digit code from 1-6): ').split('').map(&:to_i)

        if new_code.length == 4 &&
          new_code[0].between?(1, 6) && new_code[1].between?(1, 6) && new_code[2].between?(1, 6) && new_code[3].between?(1, 6)
          @code = new_code
          return new_code
        else
          clear
          puts 'Invalid choice!'
        end
      end
    end

    def game_winner(winner)
      if winner
        puts 'Computer Wins'
      else
        puts 'Player Wins'
      end
    end
  end

  def initialize
    @board = []
    @board_hint = []
    @code = []
    @winner = false

    start_game
  end

  def start_game
    puts 'Welcome to Mastermind! Where you have to guess the right code to win!'
    puts 'Would you like to play as the code guesser (1)'
    puts 'Or would you like to create a code for the computer to guess (2)?'

    loop do
      choice = (prompt 'Please enter 1 (Code Guesser) or 2 (Code Setter): ').to_i

      case choice
      when 1
        puts 'You are now playing as the code guesser! You have 12 turns to guess the right 4-digit combination'
        puts 'with the digits being 1 to 6. Take note that digits can be repeated.'
        puts 'The game will show hints with: [x][x][x][x]'
        puts 'o for correct colours in the wrong spot and O for correct colours in the correct spot'
        @guesser = PlayerGuesser.new
        @code = @guesser.generate_code
        break
      when 2
        puts 'You are now playing as the code setter! You will set a 4-digit code for the computer to guess.'
        @guesser = ComputerGuesser.new
        @code = @guesser.generate_code
        break
      else
        clear
        puts 'Invalid choice.'
      end
    end

    play_game
  end

  def print_board
    puts '-------------------------------------'
    @board.length.times do |i|
      puts "#{@board[i]} | #{@board_hint[i]} |"
      puts '-------------------------------------'
    end
  end

  def play_game
    turns = 12
    turns.times do |i|
      clear
      print_board

      puts "Guess ##{i + 1}"
      check_guess(@guesser.make_guess)

      break if @winner
    end

    clear
    print_board
    @guesser.game_winner(@winner)
  end

  def check_guess(guess)
    @board.push(guess)

    @match = @partial = 0

    code_indices = [0, 1, 2, 3]
    guess_indices = [0, 1, 2, 3]

    for i in 0..3
        if guess[i] == @code[i]
            @match += 1
            code_indices.delete(i)
            guess_indices.delete(i)
        end
    end
    guess_indices.each do |i|
      code_indices.each do |j|
            if guess[i] == @code[j]
                @partial += 1
                code_indices.delete(j)
                break
            end
        end
    end
    
    @winner = true if @match == 4

    set_board_hint
  end

  def set_board_hint
    hint = []
    4.times do |i|
      if i < @match
        hint.push('O')
      elsif i < @match + @partial
        hint.push('o')
      else
        hint.push('x')
      end
    end
    @board_hint.push(hint)
  end
end

Mastermind.new
