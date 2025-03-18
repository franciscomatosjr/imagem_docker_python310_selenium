# Usa a imagem base oficial do Ubuntu 22.04
FROM ubuntu:22.04

# Copia todos os arquivos e pastas do diretório atual para o contêiner
RUN echo "Copiando arquivos para o container..."
COPY . .

# DEBIAN_FRONTEND=noninteractive setar a variável é necessário pois a instalação do SQL Server necessita de interação
ENV DEBIAN_FRONTEND=noninteractive
ENV AMBIENTE=dev

# Serve para interação com o navegador do Chrome sem o modo headless on ubuntu
ENV DISPLAY=:99

RUN echo "Instala as dependências do sistema necessárias para o pyodbc"
RUN apt-get update && apt-get install -y \
    unixodbc \
    unixodbc-dev \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Instala o GnuPG para adicionar a chave de repositório do Google
RUN apt-get update && apt-get install -y gnupg software-properties-common && rm -rf /var/lib/apt/lists/*

RUN echo "Instalando o google chrome no conteiner..."
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN apt-get update && apt-get -y install google-chrome-stable
RUN apt-get update && apt-get install -y xvfb
RUN apt-get update && apt install -y python3 && apt install -y curl


# Baixar o Firefox
RUN wget -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=pt-BR"
# Extrair o Firefox para /opt
RUN tar -xvf firefox.tar.bz2 -C /opt/
# Limpar o arquivo baixado
RUN rm firefox.tar.bz2


SHELL ["/bin/bash", "-c"]

# Define o fuso horário para América/São Paulo
RUN echo 'America/Sao_Paulo' > /etc/timezone && dpkg-reconfigure --force tzdata

# Instala o tzdata sem interatividade
RUN apt-get update && apt-get install -y tzdata && rm -rf /var/lib/apt/lists/*

# Baixa o pacote de configuração da Microsoft para Ubuntu

RUN curl -sSL -O https://packages.microsoft.com/config/ubuntu/$(grep VERSION_ID /etc/os-release | cut -d '"' -f 2)/packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN rm packages-microsoft-prod.deb
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql18
RUN ACCEPT_EULA=Y apt-get install -y mssql-tools18
RUN echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
RUN source ~/.bashrc

# Define o diretório de trabalho
WORKDIR /app

# Instala o Python 3.10 e o pip
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3.10-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Verifica se o pip3 está associado ao Python 3.10
RUN pip3 --version
RUN pip install --upgrade pip setuptools wheel

# Instala o pyodbc
RUN pip install --upgrade pyodbc && echo "pyodbc instalado!"

# Instala o webdriver-manager
RUN pip install webdriver-manager && echo "webdriver-manager instalado"

# copia todos os arquivos do diretório atual para o container
RUN echo "Copiando arquivos para o container..."
COPY . .

# Instala dependências Python a partir do requirements.txt (se necessário)
RUN pip install --no-cache-dir -r requirements.txt

# Define o comando padrão para rodar quando o contêiner for iniciado
# Esse comando >> sh -c "Xvfb :99 -screen 0 1920x1080x24 & python3 teste_chrome.py" << serve para executar o código em que usa o Selenium sem o modo headless
CMD ["sh", "-c", "Xvfb :99 -screen 0 1920x1080x24 & python3 teste_chrome.py"]
