# Coin Ticker Pal
Simple coin tickers app that shows name, symbol, last price and relative day change of some crypto trading pairs with USD. Done for demonstration purposes using [Bitfinex API](https://docs.bitfinex.com/reference/rest-public-tickers).

## Description
This mini project makes use of `async / await` and `Combine` in order to get a list of available tickers and map them to their coresponding symbol. A polling mechanism is implemented using `AsyncStream` in order to refresh the data every 5 seconds, the list being updated using `Diffable Data Source`.

## Remaining
- improve image loading mechanism (currently Bitfinex doesn't return image URLs for coins, so the URLs are hardcoded for the sake of simplicity to simulate an image loading mechanism
- use new APIs for displaying cells (UIContentConfiguration, etc.)
- improve networking layer
- finish remaining tests

## User interface

https://github.com/anieduard/coin-ticker-pal/assets/15869716/56e540d6-a255-4d7d-bf00-624c79e448f0

https://github.com/anieduard/coin-ticker-pal/assets/15869716/82b11398-664b-47e4-839c-073915b8aa48

https://github.com/anieduard/coin-ticker-pal/assets/15869716/d49e70ee-7a0c-4ffe-b822-3b7a43481812

https://github.com/anieduard/coin-ticker-pal/assets/15869716/e013a65a-6661-466c-9761-fe5ddd837710
