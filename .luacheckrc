-- -*- mode: lua -*-

unused = false
redefined = false
max_line_length = 80
stds.custom = {
    globals = {
        'globals'
    },
    read_globals = {
        love = {
            fields = {
                graphics = {
                    fields = {
                        isCreated = {}
                    }
                }
            }
        }
    }
}
std = 'max+love+custom'
