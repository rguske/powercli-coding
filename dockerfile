FROM microsoft/powershell:ubuntu16.04

LABEL authors="rguske"

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y unzip && apt-get clean

# Set working directory so stuff doesn't end up in /
WORKDIR /home

# Install VMware modules from PSGallery
SHELL [ "pwsh", "-command" ]
RUN Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
RUN Install-Module VMware.PowerCLI,PowerNSX,PowervRA

# Add the PowerCLI admin script by pulling it down from my GitHub repo
SHELL [ "bash", "-c"]
RUN curl -kL https://raw.githubusercontent.com/rguske/powercli-coding/master/pwcli-admin.ps1 -o pwcli-admin.ps1

ENTRYPOINT ["/usr/bin/pwsh"]
CMD [ "./pwcli-admin.ps1" ]