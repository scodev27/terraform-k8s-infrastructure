# Setmana 8: Contenidorització

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

---

---

# Setmana 9: Orquestració Multicontenidor

### Diagrama d'Arquitectura

```text
  [Internet]
      | (Port 80)
      v
+-------------+       HTTP       +-------------------+
|             | ---------------> |                   |
|   Nginx     |                  | Backend (Python)  |
|             | <--------------- |                   |
+-------------+                  +---------+---------+
                                           |
                                           | (Persistència de dades)
                                           v
                                 +-------------------+
                                 |  Volum Docker     |
                                 |  (backend_data)   |
                                 +-------------------+
```

## Explicació de l'Arquitectura i Serveis
* **Nginx:** Actua com a servidor web frontal i punt d'entrada de la nostra infraestructura. És necessari per rebre les peticions externes i, en un futur, podria fer de proxy invers cap al backend.

* **Backend:** És la nostra aplicació web senzilla. Rep peticions HTTP per processar la lògica (en aquest cas, retornar un missatge) i interactua amb el sistema d'arxius.

Comunicació: Gràcies a Docker Compose, tots dos contenidors s'executen dins d'una mateixa xarxa interna de Docker. Això permet que es puguin comunicar directament utilitzant el nom del servei (ex. l'Nginx pot fer un ping a backend).

## Gestió de Volums i Persistència
Hem definit un volum de Docker anomenat backend_data associat al servei backend. Les dades dins dels contenidors són efímeres (s'esborren si el contenidor mor). Aquest volum enllaça un directori de la màquina host amb la ruta /app/data del contenidor. D'aquesta manera, encara que s'executi docker-compose down i es destrueixi la infraestructura, les dades persisteixen i es tornen a carregar en aixecar el sistema de nou.

## Gestió de la Configuració
Per complir amb les bones pràctiques i evitar credencials o valors "hardcodejats" al codi, utilitzem variables d'entorn. Els paràmetres (com el port de l'aplicació) s'agafen d'un fitxer local .env. Aquest fitxer està inclòs al .gitignore per no pujar secrets al repositori, però proporcionem un fitxer .env.example com a plantilla perquè qualsevol altre desenvolupador sàpiga quines variables necessita configurar per fer funcionar l'entorn.

# Setmana 10: Orquestració (Kubernetes)

Per escalar la nostra infraestructura i fer-la resilient, hem migrat els nostres contenidors a un clúster local de Kubernetes (Minikube). Hem definit la nostra infraestructura com a codi utilitzant fitxers manifest (YAML).

### Recursos de Kubernetes Utilitzats

* **ConfigMap:** * *Què és i per què el necessitem:* Ens permet extreure la configuració (com les variables d'entorn, per exemple l'`APP_PORT`) fora dels contenidors. D'aquesta manera, si hem de canviar una configuració, no cal reconstruir la imatge de Docker.
* **Deployment:** * *Què és i per què el necessitem:* És el controlador que gestiona els nostres Pods (els contenidors). Li diem quin estat volem (ex. "vull 1 rèplica de l'Nginx") i el Deployment s'encarrega de fer-ho realitat i mantenir-ho. Ho fem servir en lloc de crear Pods directament perquè ens aporta auto-curació i ens permetrà fer actualitzacions sense temps de caiguda (rolling updates).
* **Service:** * *Què és i per què el necessitem:* A Kubernetes, els Pods són efímers; si un mor i es reinicia, la seva adreça IP canvia. El Service ens proporciona una IP i un nom DNS estables. Actua com un balancejador de càrrega i un "directori" per trobar els pods vius.

### Comunicació de Xarxa

* **Comunicació Interna (Entre Pods):** Gràcies als Services, els pods no necessiten saber les IPs dels altres. L'Nginx es pot comunicar amb l'aplicació de Python simplement fent una petició HTTP al nom del servei del backend (`http://backend:8080`). El DNS intern de Kubernetes s'encarrega de traduir aquest nom al pod correcte.
* **Accés Extern:** Perquè els clients puguin accedir a l'Nginx des de fora del clúster, hem configurat el seu Service amb el tipus `NodePort`. Això obre un port específic a la màquina de Minikube que reenvia el trànsit cap a dins de l'Nginx.

### Escalat i Resiliència (Proves Realitzades)

Hem comprovat el comportament del clúster en situacions d'estrès:
1. **Escalat:** Al llançar la comanda `kubectl scale deployment nginx-deployment --replicas=3`, el Deployment crea automàticament nous Pods per absorbir la càrrega. El Service s'encarrega automàticament de repartir el trànsit entre els 3 Pods disponibles.
2. **Resiliència (Auto-curació):** Hem simulat una fallada esborrant manualment un Pod (`kubectl delete pod`). El clúster ha detectat que l'estat actual (0 pods) no coincidia amb l'estat desitjat (1 pod) i ha arrencat un contenidor nou en qüestió de segons per recuperar el servei sense intervenció manual.
