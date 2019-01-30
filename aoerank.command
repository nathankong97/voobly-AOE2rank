#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import requests, pandas as pd
from bs4 import BeautifulSoup
from datetime import date
from tabulate import tabulate
today = str(date.today())
form = {'username': USERNAME, 'password': PASSWORD}

def table(web):
    soup=BeautifulSoup(web, features='lxml')
    content = soup.find_all(name='div',attrs={'class':'comments'})[0]
    table = content.find_all("table")
    df = pd.read_html(str(table))[0]
    return df
    

with requests.Session() as s:
    # Get the cookie
    s.get('https://www.voobly.com/login')
    # Post the login form data
    s.post('https://www.voobly.com/login/auth', data=form)
    # Go to home page
    r = s.get('https://www.voobly.com/welcome')

    #open ladder's page
    ladder = s.get('https://www.voobly.com/ladder/ranking/131/0#pagebrowser1') #1-20
    ladder2 = s.get('https://www.voobly.com/ladder/ranking/131/1#pagebrowser1') #21-40    
    table1 = table(ladder.text)
    table2 = table(ladder2.text)

#format table    
result = pd.concat([table1,table2])
result = result.drop_duplicates()
result = result.drop(columns = [6])
result.columns = result.iloc[0]
result = result[1:]

#calculate the win rate
result.Wins = pd.to_numeric(result.Wins)
result.Loss = pd.to_numeric(result.Loss)
result['Winning Rate'] = (result.Wins / (result.Wins + result.Loss) * 100).round(2).astype(str) + '%'
result['Total'] = result.Wins + result.Loss
result = result.drop(columns = ['Streak'])
result.set_index('Rank')
#print(result.to_string(index=False))
#print('Update date: ', today)
print(tabulate(result, headers = 'keys',tablefmt='psql'))
