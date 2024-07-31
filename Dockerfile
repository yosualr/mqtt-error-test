# Menggunakan CentOS 7 sebagai base image
FROM centos:7

# Ganti repositori baseurl dengan URL yang aktif
RUN sed -i 's|^mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/CentOS-Base.repo && \
    sed -i 's|^#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Base.repo

# Install EPEL repository dan update sistem
RUN yum install -y epel-release && \
    yum update -y

# Install Mosquitto, Mosquitto clients, nc, dan telnet
RUN yum install -y mosquitto mosquitto-clients nc telnet wget

# Unduh dan instal Java 17 dari Oracle
RUN wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm && \
    yum localinstall -y jdk-17_linux-x64_bin.rpm && \
    rm jdk-17_linux-x64_bin.rpm

# Tambahkan konfigurasi Mosquitto
RUN echo -e "listener 1883\nallow_anonymous true" > /etc/mosquitto/mosquitto.conf

# Buat user non-root untuk menjalankan aplikasi
RUN useradd -ms /bin/bash appuser

# Set working directory ke /opt
WORKDIR /opt

# Ubah kepemilikan direktori /opt ke user non-root
RUN chown -R appuser:appuser /opt

# Copy aplikasi Spring Boot ke dalam container
COPY target/demo.jar /opt/app.jar

# Switch ke user non-root
USER appuser

# Expose port yang digunakan oleh aplikasi Spring Boot
EXPOSE 8080

# Start Mosquitto dan aplikasi Spring Boot
CMD ["sh", "-c", "mosquitto -c /etc/mosquitto/mosquitto.conf & java -jar /opt/app.jar"]
