########################
# a makefile
########################

# variables

JUMBO_COMPILE = YES

TARGETS = app1 app2 app3

# template definitions

define TARGET_TEMPLATE

 # calculate source files
 $(1)_SRCS = $$(addprefix $(1)/, $$(shell cat $(1)/module.sources))

 # calculate build options
 $(1)_DEFS = $$(shell cat $(1)/module.defs)
 $(1)_LDOPT = $$(shell cat $(1)/module.ldopt)

 # calculate dependencies
 $(1)_DEPS = $$(addsuffix .d, $$(basename $$($(1)_SRCS)))

 # calculate objects to compile
 ifeq ($(JUMBO_COMPILE),YES)
  $(1)_OBJS = $(1)/$(1).o
 else
  $(1)_OBJS = $$(addsuffix .o, $$(basename $$($(1)_SRCS)))
endif

 # calculate for inter-module dependencies
 GLOBAL_DEPS += $$($(1)_DEPS)
 GLOBAL_OBJS += $$($(1)_OBJS)
 GLOBAL_OUTS += $(1)/$(1)

 $(1)/$(1).o:
	@echo "Jumbo compiling for $(1)..."
	@sed -e 's/ *#.*//g' -e 's/\(.*\)\.\(.*\)/#include "\1.\2"/' $(1)/module.sources | grep . > $(1)/_JUMBO.cpp
	$$(CXX) -I$(shell pwd)/$(1) $$(CXXFLAGS) -c $(1)/_JUMBO.cpp -o $$@
	@rm $(1)/_JUMBO.cpp

 $(1): CFLAGS = $$($(1)_DEFS)
 $(1): CXXFLAGS = $$($(1)_DEFS)
 $(1): $(1)/$(1)
 $(1)/$(1): $$($(1)_DEPS) $$($(1)_OBJS)
	@echo "Linking $(1)..."
	$$(CXX) $$($(1)_LDOPT) $$($(1)_OBJS) -o $(1)/$(1)
endef

define METHOD_TEMPLATE
 $(1)/%.o : $(1)/%.cpp 
	@echo "Compiling:" $$@...
	$$(CXX) $$(CXXFLAGS) -c $$< -o $$@

 $(1)/%.o : $(1)/%.c
	@echo "Compiling:" $$@...
	$$(CXX) $$(CFLAGS) -c $$< -o $$@

 $(1)/%.d : $(1)/%.cpp
	@echo "Generating dependency:" $$@...
	$$(CXX) $$(CXXFLAGS) -MM -MT $$(addsuffix .o, $$(basename $$@)) -MF $$@ $$<

 $(1)/%.d : $(1)/%.c
	@echo "Generating dependency:" $$@...
	$$(CXX) $$(CFLAGS) -MM -MT $$(addsuffix .o, $$(basename $$@)) -MF $$@ $$<
endef

# eval templates

$(foreach i,$(TARGETS),$(eval $(call TARGET_TEMPLATE,$(i))))
$(foreach i,$(TARGETS),$(eval $(call METHOD_TEMPLATE,$(i))))

# define targets

all: $(TARGETS)
	@echo Success!
	@ls -la $(GLOBAL_OUTS)
clean:
	-rm -f $(GLOBAL_DEPS) $(GLOBAL_OBJS) $(GLOBAL_OUTS)
.DEFAULT_GOAL := all

# include dependencies

include $(GLOBAL_SRCS:%.cpp=%.d)
