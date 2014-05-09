# Filename:  plot4.R

# assume file resides in same directory as the script
# and it is un zipped already

filename="household_power_consumption.txt"


# INPUT:
#  csv file containing over 2MM rows
#  keyed on date and time
#
# Preprocessing strategy:
#  STEP 1: read the file using the fread() function from package data.table
#  which is much faster then reading the file as a data.frame.
#
#  STEP 2: subset the file to the dates Feb 1, 2007 and Feb 2, 2007
#   
#  STEP 3: since data.table does not work well with POSIXct dates,
#  convert the selected records back to a data frame
#
#  STEP 4: convert dates and times to a POSIXct date format
#
#  After that, we can draw our plots


require(data.table)

# read in the file as a data.table, which is an improved data.frame
# fread is a more flexible and faster version of read.table
# and can be found in the data.table package

dt <- NULL
dt.all<- NULL

dt.all <- fread(filename, na.strings=c("?") ) # , nrows=10,
setkeyv(dt.all, c("Date", "Time"))

# convert dates first, it will make it easier to select on date 

dt.all[, Date := as.Date(Date, format = "%d/%m/%Y")]
date1 <- as.Date("02/01/2007", format="%m/%d/%Y")
date2 <- as.Date("02/02/2007", format="%m/%d/%Y")
dt <- dt.all[ Date == date1 | Date == date2 ]

# the 'na.strings' option in 'fread' choked on the '?' for NA's
# so we still need to convert the character fields to numeric

dt[, Global_active_power := as.numeric(Global_active_power)]
dt[, Global_reactive_power := as.numeric(Global_reactive_power)]
dt[, Voltage := as.numeric(Voltage)]
dt[, Global_intensity := as.numeric(Global_intensity)]
dt[, Sub_metering_1 := as.numeric(Sub_metering_1)]
dt[, Sub_metering_2 := as.numeric(Sub_metering_2)]
dt[, Sub_metering_3 := as.numeric(Sub_metering_3)]


dim(dt)
class(dt)

# convert the data.table back to dataframe

df <- as.data.frame(dt)
dim(df)
class(df)

# convert Date and Time fields to one datetime field of class POSIXct

df$datetime <- strptime(paste(as.character(df$Date), df$Time), "%Y-%m-%d %H:%M:%S")
class(df$datetime)  # should be POSIXct


# Plot 4 - histogram of Global Active Power for dates 02/01/2007 and 02/02/2007


png(filename="plot4.png", width=480, height = 480)


par(mfrow = c(2,2))

#  plot 1  - global active power

plot(x = df$datetime, y = df$Global_active_power,
     type = "l",
     ylab = "Global Active Power",
     xlab = "", 
     col = "black")


# plot 2 - voltage

plot(x = df$datetime, y = df$Voltage,
     type = "l",
     ylab = "Voltage",
     xlab = "datetime", 
     col = "black")

# plot 3 - each of the three sub metering

plot(x = df$datetime, y = df$Sub_metering_1,
     type = "l", col="black",
     ylab = "Energy sub metering",
     xlab = "")
lines(x = df$datetime, y = df$Sub_metering_2,
      type = "l", col="red" )
lines(x = df$datetime, y = df$Sub_metering_3,
      type = "l", col="blue" )
legend("topright", 
       legend=c("Sub_metering_1","Sub_metering_2","Sub_metering_3"),
       col=c("black","red","blue"),
       border = "",
       lty  = "solid", lwd = 2
)


# plot 4 - global reactive power

plot(x = df$datetime, y = df$Global_reactive_power,
     type = "l",
     ylab = "Global Reactive Power",
     xlab = "datetime", 
     col = "black")


par(mfrow = c(1,1))

dev.off()
