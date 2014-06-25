#!/usr/bin/env ruby

##### Define Class

class WordPermutator
  
  #Function to check for valid entry, initialize instance
  #variables (described further below).
  
  def initialize(wordIn)
    
    #Define function to validate input
    
    def validateInput(input)
    
      errorMessage = "\nAborted. The word must contain 2 to 25 uppercase characters, " +
      "and at least two different letters.\n\n"
        
      #Abort if word does not match criteria: must be uppercase characters
      #Between 2 and 25 characters
      
      if !(input.match(/^[A-Z]{2,25}$/))
        abort(errorMessage)
      end
        
      #Abort if there are not at least two different letters.
      
      if !(input.match(/^([A-Z])(?!\1+\b).+$/))
        abort(errorMessage)
      end
    end
    
    #validate input
    
    validateInput(wordIn)
    
    #initialize instance variables (described further below)
    
    @uniqueLetterCount = 0
    @totalLetterCount = 0
    @multiLetterDivisor = 1
    @alphabeticalPosition = 0
    
    ##### Convert input word to array of chars, sort array, find no of letters
    
    @arrayOfChars = wordIn.chars.to_a #input word converted to array of chars
    @sortedWord = @arrayOfChars.sort #input word alphabetically sorted array
    @length = @arrayOfChars.length #number of letters in input word
    
    #Hash table to hold date for each unique letter in word
    @letterHash = Hash.new{|hash, key| hash[key] = {"alphabeticalIndex" => 0,
    "occurrencesOfLetter" => 0, "totalLettersBefore" => 0}}  

  #--------------------------------------------------------------
  
  ##### Variables Explained
  
  #These instance variables track running totals.
  
  #@uniqueLetterCount tracks unique letters. Duplicate A in AAACB gives
  #@uniqueLetterCount = 3 (A, B, and C)    
  
  #totalLettersCount keeps track of total number of letters. AAACB gives
  #totalLettersBefore = 4 for letter C (3 A's + 1 B).
  
  #@multiLetterDivisor keeps track of correction needed for multiple
  #letter occurrences. Consider AAB. Use A1 and A2 to distinguish
  #between the two As. Then A1A2B and A2A1B is treated the same: AAB.
  #For this reason, total permutations must be divided by 2!.
  #@multiLetterDivisor keeps track of the number to be used for this
  #corrective division and spans all letters collectively. Thus, we
  #avoid having to parse the hash each time we are calculating the
  #number of preceding permutations as parse the given word.
  
  #Consider CAAAB to see what must happen if there are two letters
  #with multiple occurrences. If there are 3 A's and 2 B's then the
  #global division factor holds 3! * 2! = 12. As letters get consumed,
  #this global division factor is updated. If one A gets consumed then
  #it is #divided by 3 (the number of A's available at that time):
  #12/3 = 4. So now it accounts for 2 A's and 2 B's = 2! * 2! = 4.

  #This hash stores data for each letter by using another hash inside
  #the outter one. The outer hash uses the letter as the key to access
  #the hash for each letter. The inner hash stores (1) alphabetical index,
  #(2) occurrences of letter, and (3) total letters before. Another option
  #is to define a class for letter, and use that instead of inner hash. I
  #used inner hash for sake of simplicity and efficiency.

  end #end initialize

  #---------------------------------------------------------------

  #Function to parse sorted array, create hash table

  def createHashTable()
  
  #Loop to parse alphabetically sorted letters in given word,
  #create hash table

    for i in 0..@sortedWord.length-1
      currentLetter = @sortedWord[i]
    
    #Check if currentLetter already has entry. If so, increment currentLetter's 
    #occurrencesOfLetter. Then multiply it with global @multiLetterDivisor. If
    #letter has 2 occurrences, @multiLetterDivisor gets multiplied by 2. If it
    #has 3 occurrences, it gets multiplied by 2 and then 3, which is 3!
    #So when hash table is complete, @multiLetterDivisor globally tracks total
    #factorial division needed spanning all letters
    
      if @letterHash.has_key? currentLetter
        @letterHash[currentLetter]["occurrencesOfLetter"] =
          @letterHash[currentLetter].fetch("occurrencesOfLetter", 0) + 1
        @multiLetterDivisor *= @letterHash[currentLetter]["occurrencesOfLetter"]
        
      #if no entry exists then first occurrence of this letter.
      #Assign global @uniqueLetterCount to this letter's alphabetical index
      #Set occurrencesOfLetter to 1. Increment @uniqueLetterCount.
      
      else
        @letterHash[currentLetter]["alphabeticalIndex"] = @uniqueLetterCount
        @letterHash[currentLetter]["occurrencesOfLetter"] = 1
        @uniqueLetterCount += 1
        
        #For first letter in alphabetical sequence, totalLettersBefore is 0.
        #For all others, set it to global @totalLetterCount
        
        if (@uniqueLetterCount == 0)
          @letterHash[currentLetter]["totalLettersBefore"] = 0
        else
          @letterHash[currentLetter]["totalLettersBefore"] = @totalLetterCount
        end  
      end
    
      #1 letter has been added to hash table. Increment global
      #@totalLetterCount
    
      @totalLetterCount += 1
    end
  end
  
  #---------------------------------------------------------------
  
  #function that returns factorial of argument
  #This function is used by that which calculates number
  #of permutations still available. Used by functions returnPermutationsBefore
  #and printAlphabeticalPositionUserFriendly
  
  def getFactorial(number)
    factorial = 1
    if number > 0
      for i in 1..number
        factorial *= i
      end
    end
    return factorial
  end
  
  #---------------------------------------------------------------
  
  #Function to print hash table
    
  def printHashTable
    puts "Hash: "
    @letterHash.each_pair{ |k,v| puts "#{k}: #{v}"}
  end

#---------------------------------------------------------------

# Function to calculate number of permutations that alphabetically
#precede current word

  def returnPermutationsBefore(multiLetterDivisor)
    
  #Define functions used by this function
  
  #---------------------------------------------------------------  
    
  #function that returns sum of all elements before given position
  #This function is used to track how many alphabetically preceding
  #letters are still available for our mathematical calculation
  
    def sumPrecedingArrayEntries(array, position)
      sum = 0
      for i in 0..position-1
        sum += array[i]
      end
      return sum
    end

  #---------------------------------------------------------------
  
  #Function that calculates the permutations that can alphabetically
  #precede the given spot in word using given parameters. This function gives
  #the count for each letter and its results are summed together.
  
    def findPermutationsBefore(noToPermutate, availablePrecedingLetters,
      multiLetterDivisor) 
      return (getFactorial(noToPermutate-1) * availablePrecedingLetters) / (multiLetterDivisor)
    end
    
  #---------------------------------------------------------------

    #variable for running count of permutations that alphabetically
    #precede the given word as we loop and parse through given word
    
    permutationsBefore = 0
    
    #Array to keep track of which letters have been consumed.
    #Could also update totalLettersBefore in hash table
    #and parse hash table but array better suited for sequential
    #parsing by index
    
    usedLettersArray = Array.new(@uniqueLetterCount, 0)
    
    #Loop to parse through @arrayOfChars (original, unsorted word)
    
    for i in 0..@length-2
      
      #For sake of readability, use currentLetterData to reference
      #inner hash for each letter.
      #Thus @letterHash[@arrayOfChars[i]]["totalLettersBefore"] becomes
      #currentLetterData["totalLettersBefore"]
      
      currentLetterData = @letterHash[@arrayOfChars[i]]
      
      #sumPrecedingArrayEntries parses usedLettersArray and returns
      #the sum of all entries prior to given index (alphabetical
      #index of currentLetter). Thus, this call returns number of
      #consumed letters that precede currentLetter
    
      qtyPrecedingUsedLetters = sumPrecedingArrayEntries(usedLettersArray,
        currentLetterData["alphabeticalIndex"])
      
      #update qtyPrecedingAvailableLetters by subtracting used letters
      #from currentLetter's totalLettersBefore obtained from hash table. 
      
      qtyPrecedingAvailableLetters = currentLetterData["totalLettersBefore"] -
        qtyPrecedingUsedLetters
      
      #Add the permutations for current spot to running total.
      
      permutationsBefore += findPermutationsBefore(@length-i,
        qtyPrecedingAvailableLetters, multiLetterDivisor)
      
      #To prepare for next iteration, update multiLetterDivisor as needed
      #after consuming current character. Update usedLettersArray after
      #updating multiLetterDivisor. NOTE: multiLetterDivisor is a copy
      #of instance variable @multiLetterDivisor. Copy is used so that
      #@multiLetterDivisor remains preserved for other functions such as
      #printAlphabeticalPositionUserFriendly
      
      #To see how multiLetterDivisor works, imagine a word with 3 A's.
      #Initially this letter contributes 3! to multiLetterDivisor.
      #After 1 A is used, we divide multiLetterDivisor by
      #(occurrences of A - number of A's consumed). We make this update
      #Before updating usedLettersArray. So for first consumption
      #multiLetterDivisor gets divided by 3-0 = 3. After dividing by 3 A
      #contributes 3!/3 = 2! to the collective divisor. Next time A is consumed
      #multiLetterDivisor gets divided by 3-1 = 2. So after 2 A's are
      #consumed, A contributes 2!/2 = 1 to multiLetterDivisor.
      
      multiLetterDivisor /= (currentLetterData["occurrencesOfLetter"] -
        usedLettersArray[currentLetterData["alphabeticalIndex"]])
      usedLettersArray[currentLetterData["alphabeticalIndex"]] += 1
    end
    return permutationsBefore
  end

#---------------------------------------------------------------
  
  #Function to get alphabetical position of current word by adding
  #1 to permutationsBefore 
  def getAlphabeticalPosition()
    
    @alphabeticalPosition = returnPermutationsBefore(@multiLetterDivisor) + 1
    
  end

#---------------------------------------------------------------
  
  #Function to print simply a number that is the alphabetical position of
  #given word in list of sorted words possible from letters of word

  def printAlphabeticalPositionSimple()
    
  #running total of permutationsBefore gives us number of words that precede
  #the given word. Add 1 to get position of given word.
  
  #Uncomment print statement below for more meaningful, user friendly output
  
  #print "The alphabetical position of #{ARGV[0]} is: "
  
    puts @alphabeticalPosition
    
  end
    
#---------------------------------------------------------------
    
  #Function to print user friendly report. It lists the word, total permutations,
  #and alphabetical position of current word.
   
  def printAlphabeticalPositionUserFriendly()
      
  puts "Given word is #{word}." +
    "Total words from this combination of letters is " +
    (getFactorial(@length)/@multiLetterDivisor).to_s + "."
  
    print "The alphabetical position of #{word} is: "
  
    puts @alphabeticalPosition
  end
  
end #Class
