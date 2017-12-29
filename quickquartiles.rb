require 'csv'
require 'date'

#I highly recommend "minifying" the extracts to just the columns needed here: SchoolName, SchoolYear, Grade, PercentileRank, WindowName, ScreeningCategoryGroupAdjustment
$readingfile = '/path/to/readingextractmin.csv'
$readingfile = '/path/to/mathextractmin.csv'

$testfile = '/path/to/testfile.csv'

#initialize some variables for first run-through
$counter = 0
$addyear = "y"

#write a csv to make sure the exclude and narrow functions work. Uncomment it any time you want to see the current data.
def test()
  CSV.open($testfile,"wb") do |csv|
    $reading.each do |row|
      csv << row
    end
  end
end

#user interaction to choose options read from csv
def choice(options, name)
  puts "Which #{name}?"
  c = 1
  options.each do |w|
    puts "#{c}) #{w}"
    c += 1
  end
  whichoption = gets.chomp.to_i
  return options[whichoption -1]
end

#delete rows matching options
def narrow(header, choice)
  $reading.delete_if do |row|
    row[header] != choice
  end
end

def maketable(subject, file)
  productfile = file

  #read the file
  $reading = CSV.read(productfile, headers:true)

  #exclude results without category benchmark, windows, or schools
  $reading.delete_if do |row|
    row["ScreeningCategoryGroupAdjustment"].nil? || row["WindowName"].nil? || row["SchoolName"].nil?
  end
  
  #schoose a schoolyear
  if $schoolyear.nil?
    $schoolyears = $reading["SchoolYear"].uniq!.sort!
    $schoolyear = choice($schoolyears,"schoolyear")
  end
  narrow("SchoolYear",$schoolyear)
  
  # choose a window
  if $window.nil?
    windows = $reading["WindowName"].uniq!
    $window = choice(windows,"window")
  end
  narrow("WindowName",$window)

  #test()

  #choose a school
  if $school.nil?
    schools = $reading["SchoolName"].uniq!.sort!
    $school = choice(schools,"school")
    $quartsngrades << ["#{$school}"]
  end
  narrow("SchoolName",$school)

  #test()
  
  $quartsngrades << ["#{subject} #{$schoolyear}","K","1st","2nd","3rd","4th","5th","6th","7th","8th"]
  $quartsngrades << ["Quartile 1: < 25%",0,0,0,0,0,0,0,0,0]
  $quartsngrades << ["Quartile 2: 25 - 49%",0,0,0,0,0,0,0,0,0]
  $quartsngrades << ["Quartile 3: 50 - 74%",0,0,0,0,0,0,0,0,0]
  $quartsngrades << ["Quartile 4: > 75%",0,0,0,0,0,0,0,0,0]
  $quartsngrades << [""]
  
  # count students in each grade at each quartile
  $reading.each do |row|
    pr = row["PercentileRank"].to_i
    index = row["Grade"].to_i + 1
  
    if pr < 25
      $quartsngrades[2+$counter*6][index] += 1
    elsif pr < 50
      $quartsngrades[3+$counter*6][index] += 1
    elsif pr < 75
      $quartsngrades[4+$counter*6][index] += 1
    else
      $quartsngrades[5+$counter*6][index] += 1
    end
  end
  
  $counter+=1
end

#set up 2d array for storing counts
$quartsngrades = []

#call the main function
maketable("Reading",$readingfile)
maketable("Math",$mathfile)

while $addyear == "y"
  puts "Would you like to add another year? y/n"
  $addyear = gets.chomp
  
  if $addyear=="y"
    $schoolyear = nil
    $window = nil
    maketable("Reading",$readingfile)
    maketable("Math",$mathfile)
  end
end

#create the folder and set the file for output
Dir.mkdir("/path/to/Quartile Reports/#{$school}") unless File.exists?("/path/to/Quartile Reports/#{$school}")
$outfile = "/path/to/Quartile Reports/#{$school}/#{$school} Quartiles.csv"

#write results to a new csv
CSV.open($outfile,"wb") do |csv|
  $quartsngrades.each do |row|
    csv << row
  end
end

# exec "open #{$outfile}"
