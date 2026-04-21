# Pràctica 2 GSX - Setmana 8: Contenidorització

Aquest repositori conté la resolució de la Setmana 8 de la Pràctica 2, on hem contenidoritzat dues aplicacions utilitzant Docker.

## 1. Contenidor Nginx

**Explicació del Dockerfile i elecció de la imatge base:**
Tal com s'indica a l'enunciat, per a aquest servei hem utilitzat la imatge base `nginx:latest`. Hem triat aquesta imatge perquè és la versió oficial proporcionada per Nginx, ens assegura tenir l'entorn llest per servir contingut web de manera eficient fora de la capsa. El nostre `Dockerfile` simplement parteix d'aquesta base i inclou la nostra configuració personalitzada de la Pràctica 1.

**Dependències:**
Aquesta aplicació no té cap dependència externa que s'hagi d'instal·lar; només depèn de l'Nginx que ja ve integrat a la imatge base.

## 2. Contenidor Backend (Aplicació simple)

**Dependències:**
Aquesta aplicació fa servir exclusivament les llibreries per defecte per processar les peticions HTTP, per la qual cosa no cal cap instal·lació addicional amb gestors de paquets.

---

## Instruccions de construcció i execució local

A continuació es detallen els passos per construir i provar els contenidors a l'entorn local.

### Nginx
1. **Construir la imatge localment:**
   `docker build -t nginx-gsx .`
2. **Provar en local:**
   `docker run -p 80:80 nginx-gsx`
3. **Verificació:** Es pot comprovar executant `curl localhost` o obrint el navegador per veure el lloc web actiu.

### Backend
1. **Construir la imatge localment:**
   `docker build -t backend-gsx .`
2. **Provar en local:**
   `docker run -p 8080:8080 backend-gsx`
3. **Verificació:** Es pot comprovar accedint a `localhost:8080` per verificar que retorna la resposta correcta.

---

## Execució des de Docker Hub

Les imatges s'han etiquetat i pujat al repositori públic de Docker Hub perquè qualsevol les pugui descarregar i executar:

* **Nginx:** `docker run -p 80:80 scodev27/nginx-gsx:v1`
* **Backend:** `docker run -p 8080:8080 scodev27/backend-gsx:v1`
