library(sqldf)  # loading this package to help us get only select rows of the input data

# Code to download data from data url specified into temp file, and unzip it (into household_power_consumption.txt), then zap temp file
dataUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
tempDataFile <- tempfile()
download.file(dataUrl, tempDataFile)
unzip(tempDataFile)
unlink(tempDataFile)

# data header + sample data line:
# Date;Time;Global_active_power;Global_reactive_power;Voltage;Global_intensity;Sub_metering_1;Sub_metering_2;Sub_metering_3
# 1/2/2007;00:00:00;0.326;0.128;243.150;1.400;0.000;0.000;0.000
# Note that month and day do not have leading zeroes.

# Load data; sql command specifies dates to load data for
selectedData <- read.csv2.sql(file="household_power_consumption.txt", na.strings="?", 
                              dec=".", sep=";", header=TRUE,  
                              colClasses=c(rep("character", 2), rep("numeric", 7)),
                              comment.char="",
                              sql="select * from file where Date = '1/2/2007' OR Date = '2/2/2007'"
)

# now plot graph
png(file="plot1.png", height=480, width=480, units="px")
with(selectedData, hist(Global_active_power, col="red", 
                        xlab="Global Active Power (kilowatts)", ylab="Frequency", 
                        main="Global Active Power"))
dev.off()
