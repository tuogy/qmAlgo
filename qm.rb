class QM
## Quine-McCluskey algorithm
  attr_accessor :m, :d, :all, :level, :result, :essentials
  def initialize
    @result = []
    @essentials = []
  end


  ## get input from keyborad like '3+5+8+10'
  ## return [3,5,8,10]
  def getInput
    puts "input m(.): "
    string = gets
    string.strip!
    mlist = string.split("+")
    (0..mlist.size - 1).each do |i|
      mlist[i] = mlist[i].to_i
    end
    @m = mlist.clone
    puts "input d(.): "
    string = gets
    string.strip!
    dlist = string.split("+")
    (0..dlist.size - 1).each do |i|
      dlist[i] = dlist[i].to_i
    end
    @d = dlist.clone
    @all = @m + @d
  end

  
  ## generate the first column from [3,5,8,10]
  ## return the first column [[],[['1000',0]],[['0011',0],['0101',0],['1010',0]],[],[]]
  ## ['xxxx',0] stands for it is not prime
  ## ['xxxx',1] stands for it is prime
  def genFirstCol(minimum)
    level = Math.log2(minimum.max).floor + 1
    @level = level
    res = Array.new(level + 1)
    (0..level).each {|i| res[i] = []}
    minimum.each do |i|
      binaryString = i.to_s(2)
      ones = binaryString.count('1')
      regularBinaryString = '0' * (level - binaryString.size) + binaryString
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

  ## convert symbolic into array of minimums
  def symbol2Minimum(allEssentials)
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
  
  #generate minimum not covered by essentials
  def genMinOutOfEssentials(minimums)
    res = @m.clone
    @m.each do |i|
      count = 0
      index = nil
      (0..minimums.size - 1).each do |j|
        if(minimums[j].include?(i))
          count += 1
          index = j
        end
      end
      if(count == 1)
        @result << index
        minimums[index].each do |toDelete|
          res.delete(toDelete)
        end
      end
    end
    return res
  end
  
  def bfsForCover(min,essens)
    new_min = []
    new_min <<  min
    while true do
      min = new_min.clone
      new_min = []
      count = 0
      min.each do |i|
        essens.each do |j|
          if((i - j).empty?)
            @result << count
            return
          end
          count += 1
          new_min << i - j
        end
      end
    end
  end
  
  def recoverSymbol
    res = "A = "
    @result.each do |i|
      logic = ""
      (0..@level - 1).each do |j|
        if(@essentials[i].all?{|k| (k >> j) & 1 == 1})
          logic = logic + "A#{j}"
        elsif(@essentials[i].all?{|k| (k >> j) & 1 == 0})
          logic = logic + "A#{j}\'"
        end
      end
      res = res + (res.length == 4 ? '' : '+') +  logic
    end
    return res
  end

end

qm = QM.new
min = qm.getInput
firstCol = qm.genFirstCol(min)
allEssentials = qm.genAllEssentials(firstCol)
essens = qm.symbol2Minimum(allEssentials)
min = qm.genMinOutOfEssentials(essens)
qm.bfsForCover(min,essens)
puts qm.recoverSymbol
