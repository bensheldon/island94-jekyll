// A stand-in for Chrome's Prompt API (Gemini Nano) in system tests. It
// confirms every finding except "alot", and finds a typo in code.
(() => {
  const respond = (input) => {
    if (input.startsWith("CODE BLOCK:")) {
      const missed = input.includes("teh_value")
        ? [ { original: "teh_value", correction: "the_value", explanation: "Typo in the variable name." } ]
        : []
      return { reviews: [], missed }
    }
    const findings = JSON.parse(input.slice(input.indexOf("FINDINGS:\n") + "FINDINGS:\n".length))
    return {
      reviews: findings.map(({ id, problem, suggestions }) =>
        problem === "alot"
          ? { id, genuine: false, correction: null }
          : { id, genuine: true, correction: suggestions[0] ?? null }),
      missed: []
    }
  }
  const session = {
    clone: async () => session,
    destroy: () => {},
    prompt: async (input) => JSON.stringify(respond(input))
  }
  window.LanguageModel = {
    availability: async () => "available",
    create: async () => session
  }
})()
