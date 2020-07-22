Quick and dirty ruby util to download videos off Daily Drip before service is shut down.

### Setup
Update cred.yml with your credentials

### Run
#### Run with all options
- ruby download_videos.rb 23 single_download no_download

If you don't need any of the options in the middle
- ruby download_videos.rb 35 '' '' 1

#### Options
1st
- Integer
Where you want to start your downloads from
Note this is the number of the item on the page NOT number in overall Topic

2nd
- single_download:
If you just want to download one single file
-
3rd
- no_download
If file is in the folder already and you just need it to be renamed
Just leave blank if not needed
