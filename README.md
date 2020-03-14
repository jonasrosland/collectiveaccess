# CollectiveAccess

## About

- This image does not contain MySQL, it needs to be linked
- Contains both Providence and Pawtucket2
- Pawtucket is access by `https://domain_or_ipaddress:port/`
- Providence is accessed by `https://domain_or_ipaddress:port/providence`

## Usage

    # Run mysql container
    docker run 
        --name ca_mysql 
        -e MYSQL_USER=user 
        -e MYSQL_PW=pw
        -e MYSQL_DATABASE=collective 
        -e MYSQL_ROOT_PASSWORD=root
        -v /var/ca/mysql:/var/lib/mysql
        -d 
        mysql:5
    
    # Run the collective access container
    docker run 
        -–link ca_mysql:mysql
        -p 8080:80
        -e DB_USER=user
        -e DB_PW=pw
        -e DB_NAME=collective
        -e DISPLAY_NAME="My Archive"        # optional
        -e ADMIN_EMAIL=admin@my-archive.tld # optional
        -e SMTP_SERVER=mail.my-archive.tld  # optional
        -v /var/ca/conf:/var/www/providence/app/conf
        -v /var/ca/media:/var/www/providence/media/
        pkuehne/collectiveaccess:latest

    # Go to https://domain_or_ip:8080/providence to setup the database structure
