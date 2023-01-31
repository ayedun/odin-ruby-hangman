require "pry-byebug"
require "json"


full_dictionary_file = File.readlines("./dictionary.txt")


word_list = full_dictionary_file.select do |line|
    line.length >4 && line.length < 13
end

class Game
    def initialize
        @secret_word = ""
        @num_guesses_left = 6
        @board = []
        @current_guess =""
        @right_answer = nil
        @history = ""
    end
    def display_board
        puts @board.join(" ")
    end
    def create_board()
        @board = Array.new(@secret_word.length-1, "_ ")
    end
    def make_secret_word(word_list)
        @secret_word = word_list[rand(word_list.length)].split("")
        puts @secret_word.join(" ")
        create_board()
    end

    def pre_turn
        puts "Hello, welcome to Hangman. Please  type \"load\" to load your previous save, or type \"new\" to start a new game."
        input = gets.chomp
        if input == "load"
            load_game
        elsif input == "new"
            turn
        else
            puts "Unknown response, try again"
            pre_turn
        end
    end
    def turn
        @current_guess = ""
        
        until (@current_guess.length ==1 || @current_guess == "save")
            display_board
            @right_answer = false
            puts "Make your guess! You may guess 1 letter at a time. PLEASE NOTE: if you wish to save your progress, type \"save\", otherwise type your 1-letter guess."
            puts "Numver of guesses remaining: #{@num_guesses_left}"
            puts "These are the letters you have used already: #{@history}"
            @current_guess = gets.chomp
        end
        
        if @current_guess == "save"
            save_game
        
        else
            @history << @current_guess
        
            check_guess
        end
        

    end
    def save_game
        Dir.mkdir("saves") unless Dir.exist?("saves")
        filename = "saves/save_game.json"
        File.open(filename, "w") do |f|
            f.puts(convert_to_jason)
        end
    end
    def convert_to_jason
        JSON.dump({
            secret_word: @secret_word,
            num_guesses_left: @num_guesses_left,
            board: @board,
            current_guess: @current_guess,
            right_answer: @right_answer,
            history: @history
        })
    end

    def load_game
        filename = "./saves/save_game.json"
        File.open(filename, "r") do |f|
            from_json(f)
        end
    end
    

    def from_json(file)
        json_file = JSON.parse(File.read(file))
        p json_file["secret_word"]
        @secret_word = json_file["secret_word"]
        @num_guesses_left = json_file["num_guesses_left"]
        @board = json_file["board"]
        @current_guess = json_file["current_guess"]
        @right_answer = json_file["right_answer"]
        @history = json_file["history"]
        puts "Save loaded successfully"
        turn

    end


    def check_guess
        @secret_word.each_with_index do |letter, index|
            if letter == @current_guess
                @board[index] = letter
                @right_answer = true
            end
        end
        if @right_answer == true
            @num_guesses_left +=1
            @right_answer == nil
        end
        check_end
    end

    def check_end
        if @board.none? { |letter| letter == "_ " }
            display_board
            puts "You guessed all the letters correctly, you win!"
            exit
        elsif ((@num_guesses_left -1) == 0)
            display_board
            puts "You ran out of guesses, you lose!"
            puts @num_guesses_left
        else
            @num_guesses_left -=1
            turn
        end
    end
    

end





game = Game.new()
game.make_secret_word(word_list)
game.pre_turn





