# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import gpxpy
import os
import pandas as pd
import glob

INDIR = r'X:\R Stuff\Hiking App\Data'
OUTDIR = r'X:\R Stuff\Hiking App\Data'

os.chdir(INDIR)

def parsegpx(f):
    #Parse a GPX file into a list of dictoinaries.  
    #Each dict is one row of the final dataset
    
    points2 = []
    with open(f, 'r') as gpxfile:
        # print f
        gpx = gpxpy.parse(gpxfile)
        for track in gpx.tracks:
            for segment in track.segments:
                for point in segment.points:
                    dict = {'Timestamp' : point.time,
                            'Latitude' : point.latitude,
                            'Longitude' : point.longitude,
                            'Elevation' : point.elevation
                            }
                    points2.append(dict)
    return points2

files = glob.glob('*.gpx')
df2 = pd.concat([pd.DataFrame(parsegpx(f)) for f in files], keys=files)
df2.head(5)

os.chdir(OUTDIR)
df2.to_csv('hikes.csv')