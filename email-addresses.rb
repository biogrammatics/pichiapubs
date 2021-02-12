email_pattern = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b/

Dir.glob('/Users/biogrammatics/Downloads/backup-1.14.2020_16-11-14_biogramm/homedir/mail/biogrammatics.com/*/cur/*').each do |filepath|


  system `grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" #{filepath} >> /Users/biogrammatics/Desktop/biogrammatics-emails-more.txt`


end