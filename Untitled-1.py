num=int(input("Enter a number: "))
n=0
while num!=0:
    n+=1
    if num==n:
        print(n)
        print("The number is a perfect number")
        break
    else:
        print(n)
        print("The number is not a perfect number")
        continue