FROM python:3.9-bullseye
ENV PYTHONUNBUFERRED=1
RUN apt-get -qq update\ 
    && apt-get install --yes apache2 apache2-dev libapache2-mod-wsgi-py3 python3-virtualenv gettext\
    libsasl2-dev python-dev libldap2-dev libssl-dev\ 
    #&& apt-get -y install build-essential python3-dev python2.7-dev\
    #libldap2-dev libsasl2-dev slapd ldap-utils tox\
    #lcov valgrind\ 
    && a2enmod wsgi\ 
    && a2enmod status\  
    && a2enmod headers\ 
    && apt-get install wkhtmltopdf --yes       
ADD ./apache/000-default.conf /etc/apache2/sites-available/000-default.conf
ADD ./apache/status.conf /etc/apache2/mods-available/status.conf
#ADD ./apache/etc/apache2/apache2.conf /etc/apache2/apache2.conf
EXPOSE 80
WORKDIR /code
COPY requirements.txt /code/
RUN pip install mod_wsgi\ 
    && pip install -r requirements.txt
RUN pip install git+https://github.com/azure-samples/ms-identity-python-samples-common
RUN ln -sf /proc/1/fd/2 /var/log/apache2/error.log 
    # \ && ln -sf /proc/1/fd/1 /var/log/apache2/access.log 
#COPY ./registry.py /usr/local/lib/python3.9/site-packages/django/apps/registry.py
COPY . /code/
COPY ./apache/etc/apache2/apache2.conf /etc/apache2/
RUN chmod 777 /code/dotaciones_app/Documentos
RUN chmod 777 /code/json/parameters_req.json

RUN truncate -s 0 /var/www/html/index.html
# Copy the startup script into the container image
#COPY startup.sh /usr/local/bin/startup.sh

# Make the script executable
#RUN chmod +x /usr/local/bin/startup.sh

# Set the startup script as the entrypoint for the container
#ENTRYPOINT ["/usr/local/bin/startup.sh"]
CMD ["apache2ctl","-D","FOREGROUND"]
