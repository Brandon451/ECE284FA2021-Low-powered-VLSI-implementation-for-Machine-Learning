def fun(inputs):
    for i in range(9):
        '{:11b}'.format(inputs[i] + 36 * i)

li = [0, 1, 2, 6, 7, 8, 12, 13, 14]
fun(li)
