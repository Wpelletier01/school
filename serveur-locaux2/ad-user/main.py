
from dataclasses import dataclass
from subprocess import Popen,PIPE

import sys 
import os
import pandas as pd 
import random 
import string

WINDOW_BIN="C:\Windows\System32\powershell.exe"

# Seulement pour tester
LINUX_BIN="/usr/bin/pwsh"

COLUMN_NAME= [ "prenom", "nom", "groupe","username"]



@dataclass
class AdUser:
    prenom:str 
    nom:str 
    group:str
    dpasswd:str
    username:str 


    def fullname(self):

        return f"{self.prenom} {self.nom}"

    def ps_cmd_parameter(self) -> str:
        
        return f"""$parm = @{{
	        "Name" = "{self.fullname()}";  
	        "GivenName" = "{self.prenom}"; 
 	        "Surname" = "{self.nom}";
	        "DisplayName" = "{self.fullname()}" ;
 	        "SamAccountName" = "{self.username}"; 
	        "UserPrincipalName" = "{self.username}@jouke.com";
	        "AccountPassword" = $(ConvertTo-SecureString "{self.dpasswd}" -AsPlainText -Force);
	        "Enabled" = $True	
        }}"""

    


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


def gen_random_passwd() -> str:

    n = random.randint(7,9)

    return "".join(random.choice(string.ascii_letters + string.digits ) for _ in range(n))




def collect_users(fp:str) -> list[AdUser]:

    data =  pd.read_excel(fp)

    if not validate_column(data.columns):
        print("manque une ou plusieurs colonne(s) obligatoire dans le fichier passer\n" / 
              "voir comment le fichier doit etre formater")
        sys.exit(-1)

    
    if not "mdp" in data.columns:
        print("le fichier ne contient pas des mot de passe par defaut, on va en generer")
        
        mdp = []

        for _ in range(len(data["nom"])):

            mdp.append(gen_random_passwd()) 

        data["mdp"] = mdp

        data.to_excel(fp)

       
    return [AdUser(fname,lname,group,mdp,uname) for fname,lname,group,mdp,uname in zip(data['prenom'],data['nom'],data['groupe'],data["mdp"],data['username'])]  
   




def main():
    
    arg1 = str(sys.argv[1])
    
    if not os.path.exists(arg1) or not os.path.isfile(arg1):
    
        print(f"Le chemin passe en argument n'existe pas ou n'est pas un fichier")

        sys.exit(1)

    users = collect_users(arg1)
    

    for user in users:
        
        output = execute(user.ps_cmd_parameter())

        if output.fail:
        
            print(f"la declaration du parametre @parm a echoue\n\tCause:\n{output.output} ")
            sys.exit(-1)

        output = execute("New-ADUser @parm")

        if output.fail:

            print(f"la creation de l'utilisateur {user.fullname()} a echoue\n\tCause:\n{output.output}")
            print("il sera skipper")

        else:
            print(f"creation de l'utilisateur '{user.fullname()}'a reussie")


    print("completer")


def tester():
    
    mdp = gen_random_passwd()
    print(mdp)




if __name__ == "__main__":
        
    main()

    #tester()

