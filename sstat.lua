require'lfs'

	resultados = {} --table que guardará as quantidades usando as extensoes como chave

	function processaArquivo(arquivo)
		local BUFSIZE = 2^13 --abertura de arquivo baseada no exemplo do cap. 21.2.1 da doc. lua (melhor performance)
		local file = io.input(arquivo)
		local lines, rest = file:read(BUFSIZE, "*line")
		local count_linhas = 0
		local extensao = ""
		if string.find(arquivo, ".*%.([^/.\]+)") ~= nil then --expressao regular para encontrar a extensao
			extensao = string.match(arquivo,".*%.([^/.\]+)") --considera o texto depois de "." nao seguido por "/" ou "\" que tenha algo após o "."
		else 
			return --desconsidera arquivos sem extensao
		end
		if lines ~= nil then
			local _,t = string.gsub(lines, "\n", "\n")
			count_linhas = count_linhas + t
		end
		if resultados[extensao] == nil then --verifica se ja existe a extensao na table
			resultados[extensao] = count_linhas --insere
		else
			resultados[extensao] = resultados[extensao] + count_linhas --soma
		end
	end

	function processaDiretorio(diretorio)
		for file in lfs.dir(diretorio) do --percorrer todos os elementos na pasta
			if file ~= "." and file ~= ".." then --ignorar "." e ".."
				local f = diretorio..'/'..file --montar caminho do elemento
				local attr = lfs.attributes(f) --capturar os atributos do elemente(luafilesystem)
				if attr.mode == "directory" then --se for diretorio, chama a funçao recursivamente, se for arquivo, processa-o
					processaDiretorio(f)
				else
					processaArquivo(f)
				end
			end
		end
	end
	
	function aMaiorB(a,b) --funçao que compara os elementos para ordenaçao
		if a.qtde == b.qtde then --se as qtdes forem iguais, ordena pela extensao
			return a.ext < b.ext
		end
		return a.qtde > b.qtde
	end
	
	function imprimirResultados()
		listaObjetos = {} --guarda os objetos com extensao e quantidade para ordenaçao
		local total = 0
		for extensao,v in pairs(resultados) do --iterando sobre a table inicial, com string nas chaves
			table.insert(listaObjetos, {qtde = resultados[extensao], ext = extensao}) --inserindo na nova table, com inteiro na chave
			total = total+ resultados[extensao] --somando os totais antes para usar na formataçao
		end
		table.sort(listaObjetos, aMaiorB) --ordena a table com a funçao propria
		for i,v in ipairs(listaObjetos) do --itera pela nova table (ipairs <> pairs)
			local linhas_format = "" --formato o numero para imprimir alinhado
			linhas_format = string.rep(' ', string.len(total)-string.len(listaObjetos[i].qtde))
			linhas_format = linhas_format..listaObjetos[i].qtde
			print(linhas_format.." "..listaObjetos[i].ext)
		end
		print(total.." total")
	end

----------------------------------
-- INICIO DO PROGRAMA PRINCIPAL --
----------------------------------
if table.getn(arg) == 0 then error("nenhum argumeto") end --verifica se foi passado algum parametro
for i = 1, table.getn(arg) do --percorre os parametos
	if lfs.attributes(arg[i],"mode") == nil then error("argumento invalido") end --verifico parametro invalido
	if lfs.attributes(arg[i],"mode") == "file" then --se o parametro passado for um arquivo, processa-o
		processaArquivo(arg[i])
	else
		processaDiretorio(arg[i])
	end
end
imprimirResultados()
-------------------------------
-- FIM DO PROGRAMA PRINCIPAL --
-------------------------------