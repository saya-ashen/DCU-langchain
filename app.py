from langchain_huggingface.llms import HuggingFacePipeline
from langchain_core.prompts import PromptTemplate
template = """Question: {question}
Answer: Let's think step by step."""
prompt = PromptTemplate.from_template(template)

gpu_llm = HuggingFacePipeline.from_model_id(
    model_id="model/",
    task="text-generation",
    device=0 ,
    pipeline_kwargs={"max_new_tokens": 2048},
)
gpu_chain = prompt | gpu_llm
question = "What is electroencephalography?"
print(gpu_chain.invoke({"question": question}))

# 
