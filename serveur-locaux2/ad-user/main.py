
from dataclasses import dataclass
from subprocess import Popen,PIPE

import sys 
import os
import pandas as pd 
import random 
import string

# Powershell exécutable
WINDOW_BIN="C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"

# Seulement pour tester
LINUX_BIN="/usr/bin/pwsh"

# Colonne obligatoire pour le fichier excel passer pour que le script marche comme souhaité
COLUMN_NAME= [ "prenom", "nom", "groupe","username"]

# argument de powershell a ignoré
UNWANTED_ARG = [ '', '\n', '\n\t', '\t' ]


@dataclass
class AdUser:
    """ 
        Structure de donnée représentant les informations sur un utilisateur à ajouter à l'AD  
    
    """
    prenom:str 
    nom:str 
    group:str
    dpasswd:str
    username:str 


    def fullname(self) -> str:
        """ Retourne le nom au complet """
        return f"{self.prenom} {self.nom}"

    def ps_cmd_parameter(self) -> str:
        """
            Retourne les données que la classe entrepose formaté pour la commande New-ADUser            
        """

        return f"""
            -Name "{self.fullname()}" 
	        -GivenName "{self.prenom}" 
 	        -Surname "{self.nom}" 
	        -DisplayName  "{self.fullname()}" 
 	        -SamAccountName  "{self.username}" 
	        -UserPrincipalName  "{self.username}@jouke.com" 
	        -AccountPassword $(ConvertTo-SecureString "{self.dpasswd}" -AsPlainText -Force) 
	        -Enabled $True"""

    


@dataclass
class PsOutput:
    """
        Entrepose le retourne d'une commande exécuté dans PowerShell
    """
    output:str
    fail:bool 



def execute(prompt:str) -> PsOutput:
    """ execute une commande dans une session PowerShell"""

    if sys.platform == "linux":

        prompt = f"{LINUX_BIN} {prompt}"

    elif sys.platform == "win32":
        prompt = f"{WINDOW_BIN} {prompt}"
     
    else:
        
        print("votre os n'est pas suporte")
        sys.exit(-1)
    

    cmd = list(filter( lambda x: x not in UNWANTED_ARG,prompt.split(" ")))

    output = Popen(cmd,stdout=PIPE,stderr=PIPE).communicate()
    
    if output[1] != b'':
        
        return PsOutput(output[1].decode("utf-8"),True)

    
    return PsOutput(output[0].decode("utf-8"),False)


def user_exist(name:str) -> bool:
    """ regarde si un utilisateur avec le nom passé existe dans le AD """
    
    if not execute(f"Get-ADUser {name}").fail:
        
        print(f"user: {name} existe deja")
        
        return False
    
    print(f"user: {name} n'existe pas")

    return True


def group_exist(group:str) -> bool:
    """ regarde si un groupe avec le nom passé existe dans le AD """
    if execute(f"Get-ADGroup {group}").fail:
        
        return False 
   
    return True


def create_user(user:AdUser):
    """ Ajoute un utilisateur avec les info que le parametre entrepose """

    parm = user.ps_cmd_parameter()
    output = execute(f"New-ADUser {parm}")  
            


    if output.fail:
        print(f"la creation de l'utilisateur '{user.fullname()}' à echoue")
        print(f"Raison:\n{output.output}")
    
    else:


        print(f"la creation de l'utilisateur '{user.fullname()}' à reussie")

        if not group_exist(user.group):
            print(f"le groupe {user.group} n'existe pas. il sera créé")
            
            create_group(user.group)
        
        else:

            goutput = execute(f"Add-ADGroupMember -Identity {user.group} -Members {user.username}")

            if goutput.fail:

                print(f"Incapable d'ajouter {user.fullname()} au groupe {user.group}\nRaison:\n{goutput.output}")
        
            else:
                print(f"Ajout de '{user.fullname()}' au groupe {user.group} à reussie")



    
def create_group(group:str): 
    """ Ajoute un groupe avec le nom passé  """

    output = execute(f"New-ADGroup -name '{group}' -GroupScope Global")

    if output.fail:
        
        print(f"la creation du groupe '{group}' à échoué")
        
        sys.exit(-1)
     
    print(f"creation du groupe '{group}' à réussie")

    
def validate_column(columns:list) -> bool:
    """ regarde si la liste des nom de colonne passé contient tout les colonnes obligatoires """
    return all( item in columns for item in COLUMN_NAME)    


def gen_random_passwd() -> str:
    """ Génere un mot de passe aélatoire """
    n = random.randint(7,9)

    return "".join(random.choice(string.ascii_letters + string.digits ) for _ in range(n))




def collect_users(fp:str) -> list[AdUser]:
    """ Collecte tout les utilisateur dans le fichier passé """
    data =  pd.read_excel(fp)

    if not validate_column(data.columns):
        print("manque une ou plusieurs colonne(s) obligatoire dans le fichier passé\n" / 
              "voir comment le fichier doit être formaté")
        sys.exit(-1)

    
    if not "mdp" in data.columns:
        print("le fichier ne contient pas la colonne mdp par défaut, on va en generé")
        
        mdp = []

        for _ in range(len(data["nom"])):

            mdp.append(gen_random_passwd()) 

        data["mdp"] = mdp

        data.to_excel(fp)

       
    return [AdUser(fname,lname,group,mdp,uname) for fname,lname,group,mdp,uname in zip(data['prenom'],data['nom'],data['groupe'],data["mdp"],data['username'])]  
   


def main():
    
    if len(sys.argv) <= 1:
        print("vous devez passer un fichier comme argument")
        sys.exit(-1)
    
    arg1 = str(sys.argv[1])
    
    if not os.path.exists(arg1) or not os.path.isfile(arg1):
    
        print(f"Le chemin passé en argument n'existe pas ou n'est pas un fichier")

        sys.exit(1)

    users = collect_users(arg1)
    
    list(map(lambda x: create_user(x), users))

 
    print("completé")


def tester():
    
    mdp = gen_random_passwd()
    print(mdp)




if __name__ == "__main__":
        
    main()

    #tester()

