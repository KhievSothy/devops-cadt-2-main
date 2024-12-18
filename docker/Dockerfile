FROM ubuntu:24.04
RUN apt-get update
RUN apt-get install openssh-server -y

RUN mkdir /var/run/sshd

RUN echo 'root:admin' | chpasswd

# SSH allow root login via remote
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# RESTART SSH
RUN /etc/init.d/ssh restart

CMD ["/usr/sbin/sshd", "-D"]