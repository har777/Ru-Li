
#For cons in lisp. car returns first element. cdr returns rest.
class Cons
	attr_reader :car, :cdr
	def initialize(car, cdr)
		@car, @cdr = car, cdr
	end
end


#For environment chaining
class Env
	
	def initialize(parent = nil, defaults = {})
		@parent = parent
		@defs = defaults
	end

	#to bind a value to an object. In Lisp : (define a 3) binds value 3 to a.
	def define(symbol, value)
		@defs[symbol] = value
		return value
	end

	#Checks if a symbol is already defined.
	def defined?(symbol)
		#Straightforward. If the symbol already exists in @defs hash then the symbol is already defined and hence returns true.
		return true if @defs.has_key?(symbol) 
		#If the above doesnt return and @parent.nil? returns true then symbol isn't defined and hence returns false.
		return false if @parent.nil?
		#If the above also doesnt return it recursively calls defined? again but in the @parent environment.
		return @parent.defined?(symbol)
	end

	#the defined? function above just returns if the symbol is defined. The following lookup function returns the value if it exists.
	#The comments for defined? applies here as well.
	def lookup(symbol)
		return @defs[symbol] if @defs.has_key?(symbol)
		raise "Sorry mate. Symbol #{symbol} has no value :( If it bothers you just define it a value using define :) " if @parent.nil?
		return @parent.lookup(symbol)
	end

	#set is used to change the value to a symbol already defined.
	def set(symbol, value)
		#Change if exists.
		if @defs.has_key?(symbol)
			@defs[symbol] = value
		#If above is null and no parent environment exists send error.
		elsif @parent.nil?
			raise "Geez you cant assign a value to a symbol which is not defined :/ Peace out !! "
			raise "On a more formal note : Symbol #{symbol} isnt defined. Cannot set value #{value}"
		#Else if symbol undefined but parent exists, recursively call same function with parent.
		else
			@parent.set(symbol, value)
		end
	end		

end
