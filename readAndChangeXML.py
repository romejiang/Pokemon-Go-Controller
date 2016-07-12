#!/usr/bin/env python

import xml.etree.cElementTree as ET
import urllib2
import json
import os
import time

lastLat = ""
lastLng = ""

def clickAction():
	os.system("./autoClicker -x 500 -y 463")
	time.sleep(0.5)
	os.system("./autoClicker -x 500 -y 513")
	print "clicking!!"

def getPokemonLocation():
	try:
		response = urllib2.urlopen("http://192.168.29.102:8080/", timeout = 3)
		return json.load(response)
	except urllib2.URLError as e:
		print e.reason

def generateXML():
	global lastLat, lastLng
	try:
		geo = getPokemonLocation()
	except urllib2.URLError as e:
		print e.reason
	if geo != None:
		if geo["lat"] != lastLat or geo["lng"] != lastLng:
			lastLat = geo["lat"]
			lastLng = geo["lng"]
			gpx = ET.Element("gpx", version="1.1", creator="Xcode")
			wpt = ET.SubElement(gpx, "wpt", lat=geo["lat"], lon=geo["lng"])
			ET.SubElement(wpt, "name").text = "PokemonLocation"
			ET.ElementTree(gpx).write("pokemonLocation.gpx")
			print "Location Updated!", "latitude:", geo["lat"], "longitude:" ,geo["lng"]
			clickAction()
		else:
			print "Location not changed"
	else:
		print "Location is nil!"

	time.sleep(1)

def start():
	while True:
		generateXML()

start()