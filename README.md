# 🚀 Projeto: Selenium + Chrome no Docker

Este repositório contém um ambiente Docker configurado para rodar scripts Selenium utilizando Google Chrome e ChromeDriver em modo headless.

## 📌 Pré-requisitos
Antes de iniciar, certifique-se de ter instalado:
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## 🏗 Construindo a Imagem Docker
Para criar a imagem, execute o seguinte comando:
```sh
docker build -t selenium-chrome-container .
```

## ▶️ Executando o Contêiner
Para iniciar o contêiner e abrir um shell interativo:
```sh
docker run --rm -it selenium-chrome-container /bin/bash
```

## 🛠 Testando a Instalação do Chrome
Dentro do contêiner, execute:
```sh
google-chrome --version
```
Se o Chrome estiver instalado corretamente, ele retornará algo como:
```
Google Chrome 121.0.6167.85
```

Para testar o Chrome em modo headless:
```sh
google-chrome --headless --no-sandbox --disable-dev-shm-usage --remote-debugging-port=9222 https://www.google.com
```
Se não houver erros, significa que o Chrome foi configurado corretamente.

## 🔍 Testando Selenium com Chrome
Dentro do contêiner, inicie o Python:
```sh
python3.11
```
E execute o seguinte script para testar o Selenium:
```python
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options

options = Options()
options.add_argument("--headless")
options.add_argument("--no-sandbox")
options.add_argument("--disable-dev-shm-usage")

service = Service("/usr/local/bin/chromedriver")
driver = webdriver.Chrome(service=service, options=options)
driver.get("https://www.google.com")
print(driver.title)
driver.quit()
```
Se o título da página "Google" for impresso, o Selenium está funcionando corretamente.

## ❌ Possíveis Erros e Soluções
### 1. **Erro: `Failed to connect to the bus: No such file or directory`**
**Solução:** Certifique-se de que os pacotes `dbus-x11` e `libgbm-dev` estão instalados.

### 2. **Erro: `xcb_connect() failed, error 1`**
**Solução:** Adicione os pacotes `libx11-xcb1`, `libxi6`, `libxrandr2`, `libxcomposite1`.

### 3. **Erro: `Running as root without --no-sandbox is not supported`**
**Solução:** Sempre execute o Chrome com `--no-sandbox`.

## 📜 Licença
Este projeto é distribuído sob a licença MIT. Sinta-se à vontade para usar e modificar!

