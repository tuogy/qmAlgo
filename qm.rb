## Quine-McCluskey algorithm

class QM
  attr_accessor :m, :d, :all, :level, :result, :essentials
  def initialize
    @result = []
    @essentials = []
  end

  ## get input from file
  ## return [3,5,8,10]
  def getInput
    mlist = []
    mintermFile = File.new('minterm','r')
    mintermFile.each_line do |line|
      line = line.strip
      if(line.empty?)
        next
      end
      mlist << line.to_i
    end
    @m = mlist.clone
    dlist = []
    dontknowFile = File.new('dontknow','r')
    dontknowFile.each_line do |line|
      line = line.strip
      if(line.empty?)
        next
      end
      dlist << line.to_i
    end
    @d = dlist.clone
    @all = @m + @d
    if(@all.empty?)
      return
    end
    @level = Math.log2(@all.max).floor + 1
  end
  
  ## generate the first column from [3,5,8,10]
  ## return the first column [[],[['1000',0]],[['0011',0],['0101',0],['1010',0]],[],[]]
  ## ['xxxx',0] stands for it is not essential
  ## ['xxxx',1] stands for it is essential
  def genFirstCol()
    minterm = @all.clone
    res = Array.new(@level + 1)
    (0..@level).each {|i| res[i] = []}
    minterm.each do |i|
      binaryString = i.to_s(2)
      ones = binaryString.count('1')
      regularBinaryString = '0' * (@level - binaryString.size) + binaryString
      res[ones] << [regularBinaryString, 1]
    end
    return res
  end

  ## match two strings diff at only one character 0/1
  def match(str1, str2)
    res = true
    diff = nil
    (0..str1.length - 1).each do |i|
      if(str1[i] == str2[i])
        next
      elsif (str1[i] == '-' or str2[i] == '-')
        res = false
      elsif (diff == nil)
        diff = i
      else
        res = false
      end
    end
    union = str1.clone
    if(res == true)
      union[diff] = '-'
    end
    return [res, union]
  end

  ## extract primes from two sets
  def extractPrimes(set1, set2)
    res = []
    (0..set1.size - 1).each do |i|
      (0..set2.size - 1).each do |j|
        matchResult = self.match(set1[i][0],set2[j][0])
        if(matchResult[0])
          set1[i][1] = 0
          set2[j][1] = 0
          res << [matchResult[1], 1]
        end
      end
    end
    res.uniq!
    return res
  end

  ## generate next column
  def genNextCol(col)
    res = Array.new(col.size - 1)
    (0..col.size - 2).each do |i|
      res[i] = self.extractPrimes(col[i], col[i + 1])
    end
    return res
  end

  ## generate all essentials
  def genAllEssentials(firstCol)
    allPrimes = firstCol.clone
    nextCol = self.genNextCol(firstCol)
    while(check = nextCol.uniq; check.delete([]);  not check.nil? and not check.empty?)
      allPrimes = allPrimes + nextCol
      nextCol = self.genNextCol(nextCol)
    end
    res = []
    allPrimes.each do |set|
      set.each do |i|
        if(i[1] == 1)
          res << i[0]
        end
      end
    end
    return res
  end

  ## convert symbolic into array of minterms
  def symbol2Minterm(allEssentials)
    res = []
    allEssentials.each{|str| res << [str]}
    operated = true
    while(operated)
      operated = false
      (0..res.size - 1).each do |i|
        (0..res[i].size - 1).each do |j|
          if(index = res[i][j].index('-'))
          zero = res[i][j].clone
          one = res[i][j].clone
          zero[index] = '0'
          one[index] = '1'
          res[i][j] = zero
          res[i] << one
          operated = true
          res[i].uniq!
          end
        end
      end
    end
    (0..res.size - 1).each do |i|
      (0..res[i].size - 1).each do |j|
        res[i][j] = res[i][j].to_i(2)
      end
    end
    @essentials = res
    return res
  end
  
  #generate minterm not covered by essentials
  def genMinOutOfEssentials()
    res = @m.clone
    @m.each do |i|
      count = 0
      index = nil
      (0..@essentials.size - 1).each do |j|
        if(@essentials[j].include?(i))
          count += 1
          index = j
        end
      end
      if(count == 1 and not @result.include?(index))
        @result << index
        @essentials[index].each do |toDelete|
          res.delete(toDelete)
        end
      end
    end
    return res
  end
  
  # use the BFS algorithm to cover the rest minterms
  def bfsForCover(min)
    if(min.empty?)
      return
    end
    new_min = []
    new_min <<  min
    while true do
      min = new_min.clone
      new_min = []
      count = 0
      min.each do |i|
        @essentials.each do |j|
          if((i - j).empty?)
            coverSet = count.to_s(@essentials.size)
            coverSet.each_char do |i|
              @result << i.to_i(@essentials.size)
            end
            return
          end
          count += 1
          new_min << i - j
        end
      end
    end
  end
  
  # use the greedy algorithm to get a better-but-not-best cover
  def greedyForCover(min)
    if(min.empty?)
      return
    end
    while true do 
      index = nil
      size = min.size
      @essentials.each_index do |i|
        if((min - @essentials[i]).size < size)
          index = i
          size = (min - @essentials[i]).size
        end
      end
      min = min - @essentials[index]
      @result << index
      if(size == 0)
        return
      end
    end
  end


  # tranfer the index of primes back to symbolic expressions
  def recoverSymbol
    res = "A = "
    logic_series = ""
    alphabet_series = ""

    @result.each do |i|
      logic = ""
      alphabet = ""
      (0..@level - 1).each do |j|
        if(@essentials[i].all?{|k| (k >> j) & 1 == 1})
          logic = logic + "A#{j}"
          alphabet = alphabet + (9 + @level - j).to_s(10 + @level).capitalize
        elsif(@essentials[i].all?{|k| (k >> j) & 1 == 0})
          logic = logic + "A#{j}\'"
          alphabet = alphabet + (9 + @level - j).to_s(10 + @level).capitalize + "\'"
        end
      end
      logic_series = logic_series + (logic_series.empty? ? '' : '+') +  logic
      alphabet_series = alphabet_series + (alphabet_series.empty? ? '' : '+') +  alphabet
    end
    res = res + logic_series + "\n"
    res = res + "  =  " + alphabet_series
    return res
  end

end

qm = QM.new
min = qm.getInput
if(qm.m.size == 0)
  puts "A = 0"
elsif(qm.m.size == 2 ** (qm.level - 1))
  puts "A = 1"
else
  puts "Generating essential primes..."
  firstCol = qm.genFirstCol
  allEssentials = qm.genAllEssentials(firstCol)
  qm.symbol2Minterm(allEssentials)
  puts "essentials generated. try to cover the rest minterms..."
  min = qm.genMinOutOfEssentials
  if(qm.essentials.size > 30)
    puts "The number of essentials exceeds 30, using greedy algorithm instead of BFS to quickly generate a better-but-not-best solution."
    qm.greedyForCover(min)
  else
    puts "Using BFS to generate the best solution. It may take time since it is NP-Hard."
    qm.bfsForCover(min)
  end
  puts qm.recoverSymbol
end
