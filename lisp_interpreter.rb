DEFAULTS = {
	#Arithmetic
	:+ => lambda { |x, y| x + y },
	:- => lambda { |x, y| x - y },
	:* => lambda { |x, y| x * y },
	:/ => lambda { |x, y| x / y },

	#car and cdr
	:car => lambda { |x| x.car },
	:cdr => lambda { |x| x.cdr },

	#cons
	:cons => lambda { |x, y| Cons.new(x, y) },

	:atom? => lambda { |x| x.kind_of?(Cons) ? :nil : :t },
	:eq? => lambda { |x, y| x.equal?(y) ? :t : :nil },

	:list => lambda { |*args| Cons.from_a(args) },

	:print => lambda { |*args| puts *args; :nil },

	:nil => :nil,
	:t => :t,
}
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

	###################Executing the eval of Lisp#######################

	class Object
		def eval(env, forms)
			self
		end

		def consify
			self
		end

		def arrayify
			self
		end

		def conslist?
			false
		end
	end

	class Symbol
		def eval(env, forms)
			env.lookup(self)
		end

		def arrayify
			self == :nil ? [] : self
		end

		def conslist?
			self == :nil
		end
	end

	class Array
		def consify
			map{|x| x.consify}.reverse.inject(:nil) {|cdr, car| Cons.new(car, cdr)}
		end
	end

	class Cons
		def eval(env, forms)
			return forms.lookup(car).call(env, forms, *cdr.arrayify) if forms.defined?(car)
			func = car.eval(env, forms)
			return func.call(*cdr.arrayify.map{|x| x.eval(env, forms)})
		end

		def arrayify
			return self unless conslist?
			return [car] + cdr.arrayify
		end

		def conslist?
			cdr.conslist?
		end
	end			


end
