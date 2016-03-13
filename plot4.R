library(dplyr)   # package to massage data
library(sqldf)  # package to help us get only select rows of the input data

# Code to download data from data url specified into temp file, and unzip it (into household_power_consumption.txt), then zap temp file
dataUrl <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
tempDataFile <- tempfile()
download.file(dataUrl, tempDataFile)
unzip(tempDataFile)
unlink(tempDataFile)

# Data header + sample data line:
# Date;Time;Global_active_power;Global_reactive_power;Voltage;Global_intensity;Sub_metering_1;Sub_metering_2;Sub_metering_3
# 1/2/2007;00:00:00;0.326;0.128;243.150;1.400;0.000;0.000;0.000
# Note that month and day do not have leading zeroes.

getDateTime <- function(inpDate, inpTime) {
        # helper function to combine Date and Time columns into a new column datetime
        combDateTime <- paste(inpDate, inpTime, sep=" ")
        result <- as.POSIXct(combDateTime,format="%d/%m/%Y %H:%M:%S")
        return(result)
}

# Get the relevant data
selectedData <- read.csv2.sql(file="household_power_consumption.txt", na.strings="?", 
                              dec=".", sep=";", header=TRUE,  
                              colClasses=c(rep("character", 2), rep("numeric", 7)),
                              comment.char="",
                              sql="select * from file where Date = '1/2/2007' OR Date = '2/2/2007'"
)

# Now convert to tbl form and use dplyr to modify columns
tblSelectedData <- tbl_df(selectedData)
convertedSelectedData <- tblSelectedData %>%
        mutate(datetime=getDateTime(Date,Time)) %>%   # Add a new datetime column made froim Date, Time
        select(-Date, -Time)    # zap Date and Time columns now


# Now to get to the actual plots
png(file="plot4.png", height=480, width=480, units="px")   # set up device and plot
par(mfrow = c(2,2), mar = c(4, 4, 2, 1), oma = c(0, 0, 0, 0)) #), height=480, width=480, units="px")  # plotting graphs by row, 2 x 2

#row 1, col 1
with(convertedSelectedData, plot(datetime, Global_active_power, type="l",  
                                 xlab="", ylab="Global Active Power" ))  # Using defaults where appropriate

# row 1, col 2
with(convertedSelectedData, plot(datetime, Voltage, type="l",  
                                 xlab="datetime", ylab="Voltage" ))  # Using defaults where appropriate

# row 2, col 1
plot(convertedSelectedData$datetime, convertedSelectedData$Sub_metering_1, type="n",
     xlab="", ylab="Energy sub metering" ) # Set up plot without plotting, use defaults where appropriate
# Annotate and plot
legend("topright", lty=c(1,1,1), col=c("black", "red", "blue"), legend=c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))
lines(convertedSelectedData$datetime, convertedSelectedData$Sub_metering_1,col="black")
lines(convertedSelectedData$datetime, convertedSelectedData$Sub_metering_2,col="red")
lines(convertedSelectedData$datetime, convertedSelectedData$Sub_metering_3,col="blue")

# row 2, col 2
with(convertedSelectedData, plot(datetime, Global_reactive_power, type="l",  
                                 xlab="datetime", ylab="Global_reactive_power" ))  # Using defaults where appropriate

dev.off()  # we're done !

