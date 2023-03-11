
from dataclasses import dataclass
from subprocess import Popen,PIPE

import sys 
import os
import pandas as pd 

WINDOW_BIN="C:\Windows\System32\powershell.exe"

# Seulement pour tester
LINUX_BIN="/usr/bin/pwsh"

COLUMN_NAME= [ "prenom", "nom", "groupe"]



@dataclass
class AdUser:
    prenom:str 
    nom:str 
    group:str
    dpasswd:str


    def fmt_name(self):

        return f"{self.prenom} {self.nom}"


@dataclass
class PsOutput:
    output:str
    fail:bool 



def execute(prompt:str) -> PsOutput:


  


    if sys.platform == "linux":

        prompt = f"{LINUX_BIN} {prompt}"

    elif sys.platform == "win32":
        prompt = f"{WINDOW_BIN} {prompt}"
     
    else:
        
        print("votre os n'est pas suporte")
        sys.exit(-1)
    

    cmd = prompt.split(" ")




    output = Popen(cmd,stdout=PIPE,stderr=PIPE).communicate()
    
    if output[1] != b'':
        
        return PsOutput(output[1].decode("utf-8"),True)

    
    return PsOutput(output[0].decode("utf-8"),False)


def user_exist(username:str) -> bool:
    
    
    if not execute(f"Get-ADUser {username}").fail:
        
        print(f"user: {username} existe deja")
        
        return False
    
    print(f"user: {username} n'existe pas")

    return True

def group_exist(group:str) -> bool:

    if execute(f"Get-ADGroup {group}").fail:
        
        return False 
   
    return True


def create_user(user:AdUser):
    #TODO: finish this execution
    output = execute(f"New-ADGroup -name '{user.fmt_name}' -GroupScope Global")

    if output.fail:
        print(f"la creation de l'utilisateur '{user.fmt_name}' a echoue")
        print(f"Raison:\n{output.output}")
    
    else:
        print(f"la creation de l'utilisateur '{user.fmt_name}' a reussie")

    
def create_group(group:str): 

    output = execute(f"New-ADGroup -name '{group}' -GroupScope Global")

    if output.fail:
        
        print(f"la creation du groupe '{group}' a echoue")
        
        sys.exit(-1)
     
    print(f"creation du groupe '{group}' a reussie")

    
def validate_column(columns:list) -> bool:
    
    return all( item in columns for item in COLUMN_NAME)    



def collect_users(fp:str) -> list[AdUser]:

    data =  pd.read_excel(fp)

    if not validate_column(data.columns):
        print("manque une ou plusieurs colonne(s) obligatoire dans le fichier passer\n" / 
              "voir comment le fichier doit etre formater")
        sys.exit(-1)

    
    if "mdp" in data.columns:
        return [
            AdUser(fname,lname,group,mdp) for fname,lname,group,mdp in zip(data['prenom'],data['nom'],data['groupe'],data["mdp"])]  

    print("le fichier ne contient pas des mot de passe par defaut, on va en generer")

    users = []

    for fname,lname,group in zip(data['prenom'],data['nom'],data['groupe']):

        #TODO: gen password
        mdp = ""

        users.append(AdUser(fname,lname,group,mdp))

    return users 




def main():
    
    arg1 = str(sys.argv[1])
    
    if not os.path.exists(arg1) or not os.path.isfile(arg1):
    
        print(f"Le chemin passe en argument n'existe pas ou n'est pas un fichier")

        sys.exit(1)

    users = collect_users(arg1)
    





def tester():

    data = collect_users("user-info-shrinked.xls")
    
    


    print(data)



if __name__ == "__main__":
        
    # main()

    tester()

