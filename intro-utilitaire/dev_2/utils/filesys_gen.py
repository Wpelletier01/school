
import randomfiletree
import random
import string

FILE_NAME = [
    
   "outcome",
   "month",
   "basis",
   "reflection",
   "politics",
   "product",
   "housing",
   "concept",
   "preparation",
   "mom",
   "artisan",
   "cigarette",
   "inspection",
   "possession",
   "cabinet",
   "organization",
   "menu",
   "addition",
   "ratio",
   "flight",
   "salad",
   "fortune",
   "village",
   "personality",
   "cousin",
   "news",
   "heart",
   "courage",
   "database",
   "enthusiasm",
   "cell",
   "hair",
   "contribution",
   "garbage",
   "university",
   "excitement",
   "army",
   "cookie",
   "situation",
   "proposal",
   "warning",
   "technology",
   "science",
   "bathroom",
   "worker",
   "definition",
   "perspective",
   "uncle",
   "audience",
   "painting"

]

FILE_TYPE = [

    ".txt",
    ".docx",
    ".pdf",
    ".png",
    ".jpeg",
    ".xml",
    ".html"
    
]




def generate(root,maxdepth,repeat):
    
    return randomfiletree.iterative_gaussian_tree(
            root,
            nfiles=2,
            nfolders=1,
            maxdepth=maxdepth,
            repeat=repeat,
            min_folders=1,
            min_files=1,
            filename=fname
        )[1]



def fname():

    name_index = random.randint(0,49)
    type_index = random.randint(0,6)

    return f"{FILE_NAME[name_index]}{FILE_TYPE[type_index]}"






def gen_random_string():

    length = random.randint(15,30000)

    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(length))




if __name__ == "__main__":
       

    with open("username.txt","r") as f:

        lines = f.readlines()

        for line in lines:
            if line != "":
                fline = line.replace("\n","").replace("$","")
                root = f"/home/user/school/intro-utilitaire/dev_2/filesys/{fline}"
                files = generate(root,random.randint(2,5),random.randint(2,4))

                for file in files:

                    with open(file,"w") as fw:
                        fw.write(gen_random_string())
                        fw.close()

        f.close()




        
            

            



        



 

   
   

   

