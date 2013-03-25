class QM
## Quine-McCluskey algorithm

  def initialize
    
  end


  ## get input from keyborad like '3+5+8+10'
  ## return [3,5,8,10]
  def getInput
    string = gets
    string.strip!
    res = string.split("+")
    (0..res.size - 1).each do |i|
      res[i] = res[i].to_i
    end
    return res
  end

  
  ## generate the first column from [3,5,8,10]
  ## return the first column [[],[['1000',0]],[['0011',0],['0101',0],['1010',0]],[],[]]
  ## ['xxxx',0] stands for it is not prime
  ## ['xxxx',1] stands for it is prime
  def genFirstCol(minimum)
    level = Math.log2(minimum.max).floor + 1
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
end

qm = QM.new
p min = qm.getInput
firstCol = qm.genFirstCol(min)
p qm.genAllEssentials(firstCol)
