#!/usr/bin/python

import re
import fileinput

regex = ur".*id=\"(.+?)\".*norm=\"(.+?)\".*sum=\"(.+?)\".*"
p=re.compile(regex)

timeexpsum = 0
timeactsum = 0
timeovrsum = 0

print "Date,\tExpected,\tActual,\tDeviation"
for line in fileinput.input():
	m = p.match(line);
	if m:
		timeexp = float(m.groups()[1])
		timeact = float(m.groups()[2])/3600
		timeexpsum += timeexp
		timeactsum += timeact
		timeovr = timeact-timeexp
		print m.groups()[0] + ",\t" + str(timeexp) + ",\t" + str(round(timeact,1)) + ",\t" + str(round(timeovr,1))

timeovrsum = timeactsum - timeexpsum
print "\t,\t" +  str(round(timeexpsum,1)) + ",\t" + str(round(timeactsum,1)) + ",\t" + str(round(timeovrsum,1))
